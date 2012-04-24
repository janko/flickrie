require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
require 'simple_oauth'

module Flickrie
  module OAuth
    URL = 'http://www.flickr.com/services/oauth'.freeze
    NO_CALLBACK = 'oob'.freeze

    def self.new_connection(additional_oauth_params = {})
      oauth_params = {
        :consumer_key => Flickrie.api_key,
        :consumer_secret => Flickrie.shared_secret
      }.merge(additional_oauth_params)

      Faraday.new(URL) do |connection|
        connection.request :oauth, oauth_params
        connection.use ParseFlickrResponse
        connection.adapter Faraday.default_adapter
      end.
        tap do |connection|
          connection.builder.insert_before ParseFlickrResponse, StatusCheck
        end
    end

    class StatusCheck < Faraday::Response::Middleware
      def on_complete(env)
        if env[:status] != 200
          raise Error, env[:body]['oauth_problem'].gsub('_', ' ').capitalize
        end
      end
    end

    class Error < StandardError
    end

    class ParseFlickrResponse < FaradayMiddleware::ResponseMiddleware
      dependency do
        require 'addressable/uri' unless defined?(Addressable)
      end

      define_parser do |body|
        parser = Addressable::URI.new
        parser.query = body
        parser.query_values
      end
    end

    def self.get_request_token(callback = nil)
      connection = new_connection

      response = connection.get "request_token" do |req|
        req.params[:oauth_callback] = callback || NO_CALLBACK
      end

      RequestToken.from_response(response.body)
    end

    def self.get_access_token(verifier, request_token)
      connection = new_connection \
        :token => request_token.token,
        :token_secret => request_token.secret

      response = connection.get "access_token" do |req|
        req.params[:oauth_verifier] = verifier
      end

      AccessToken.from_response(response.body)
    end

    module Token
      def from_response(body)
        new(body['oauth_token'], body['oauth_token_secret'])
      end
    end

    class RequestToken < Struct.new(:token, :secret)
      extend Token

      def get_authorization_url(options = {})
        url = Addressable::URI.parse(URL)
        url.path += "/authorize"
        url.query_values = {
          :oauth_token => token,
          :perms => options[:permissions] || options[:perms]
        }
        url.to_s
      end
    end

    class AccessToken < Struct.new(:token, :secret)
      extend Token
    end
  end
end

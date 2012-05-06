require 'faraday_middleware'
require 'faraday_middleware/response_middleware'

module Flickrie
  module OAuth
    URL = 'http://www.flickr.com/services/oauth'.freeze
    NO_CALLBACK = 'oob'.freeze

    def self.new_connection(additional_oauth_params = {})
      oauth_params = {
        :consumer_key => Flickrie.api_key,
        :consumer_secret => Flickrie.shared_secret
      }.merge(additional_oauth_params)

      Faraday.new(URL) do |conn|
        conn.use FaradayMiddleware::OAuth, oauth_params

        conn.use StatusCheck
        conn.use ParseResponseParams

        conn.adapter Faraday.default_adapter
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

    class ParseResponseParams < FaradayMiddleware::ResponseMiddleware
      define_parser do |body|
        params_array = body.split('&').map { |param| param.split('=') }
        Hash[*params_array.flatten]
      end
    end

    def self.get_request_token(options = {})
      connection = new_connection

      response = connection.get "request_token" do |req|
        req.params[:oauth_callback] = options[:callback_url] || NO_CALLBACK
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
        require 'uri'
        url = URI.parse(URL)
        url.path += "/authorize"
        params = {
          :oauth_token => token,
          :perms => options[:permissions] || options[:perms]
        }
        url.query = params.map { |k, v| "#{k}=#{v}" }.join('&')
        url.to_s
      end
    end

    class AccessToken < Struct.new(:token, :secret)
      extend Token
    end
  end
end

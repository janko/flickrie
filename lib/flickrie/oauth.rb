require 'faraday_middleware'
require 'faraday_middleware/response_middleware'

module Flickrie
  module OAuth
    URL = 'http://www.flickr.com/services/oauth'.freeze
    NO_CALLBACK = 'oob'.freeze

    private

      def self.new_connection(request_token = nil) # :nodoc:
        Faraday.new(params) do |b|
          b.use FaradayMiddleware::OAuth,
            :consumer_key => Flickrie.api_key,
            :consumer_secret => Flickrie.shared_secret,
            :token => request_token.to_a.first,
            :token_secret => request_token.to_a.last

          b.use Middleware::ParseOAuthParams
          b.use Middleware::OAuthCheck

          b.adapter :net_http
        end
      end

      def self.params
        {
          :url => URL,
          :request => {
            :open_timeout => Flickrie.open_timeout || OPEN_TIMEOUT,
            :timeout => Flickrie.timeout || TIMEOUT
          }
        }
      end

    public

    class StatusCheck < Faraday::Response::Middleware # :nodoc:
      def on_complete(env)
        if env[:status] != 200
          raise Error, env[:body]['oauth_problem'].gsub('_', ' ').capitalize
        end
      end
    end

    class Error < StandardError
    end

    class ParseResponseParams < FaradayMiddleware::ResponseMiddleware # :nodoc:
      define_parser do |body|
        params_array = body.split('&').map { |param| param.split('=') }
        params_array.map! { |params| params.count == 1 ? params << "" : params}
        Hash[*params_array.flatten]
      end
    end

    def self.get_request_token(options = {})
      connection = new_connection
      response = connection.get "request_token" do |req|
        req.params[:oauth_callback] = options[:callback_url] || NO_CALLBACK
      end

      RequestToken.new(response.body)
    end

    def self.get_access_token(verifier, request_token)
      connection = new_connection(request_token)
      response = connection.get "access_token" do |req|
        req.params[:oauth_verifier] = verifier
      end

      AccessToken.new(response.body)
    end

    module Token
      attr_reader :token, :secret

      def initialize(info)
        @token = info[:oauth_token]
        @secret = info[:oauth_token_secret]
      end

      def to_a
        [token, secret]
      end
    end

    class RequestToken
      include Token

      def get_authorization_url(params = {})
        require 'uri'
        url = URI.parse(URL)
        url.path += '/authorize'
        query_params = {:oauth_token => token}.merge(params)
        url.query = query_params.map { |k,v| "#{k}=#{v}" }.join('&')
        url.to_s
      end
      alias authorize_url get_authorization_url

      def get_access_token(verifier)
        OAuth.get_access_token(verifier, self)
      end
    end

    class AccessToken
      include Token

      attr_reader :user_info

      def initialize(info)
        super
        @user_info = info.tap do |info|
          info.delete(:oauth_token)
          info.delete(:oauth_token_secret)
        end
      end
    end
  end
end

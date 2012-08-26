require 'faraday_middleware'

module Flickrie
  module OAuth
    URL = 'http://www.flickr.com/services/oauth'.freeze
    NO_CALLBACK = 'oob'.freeze

    private

      def self.new_connection(request_token = nil)
        Faraday.new(params) do |b|
          b.use Middleware::Retry
          b.use FaradayMiddleware::OAuth,
            consumer_key: Flickrie.api_key,
            consumer_secret: Flickrie.shared_secret,
            token: request_token.to_a.first,
            token_secret: request_token.to_a.last

          b.use Middleware::ParseOAuthParams
          b.use Middleware::OAuthCheck

          b.adapter :net_http
        end
      end

      def self.params
        {
          url: URL,
          request: {
            open_timeout: Flickrie.open_timeout || DEFAULTS[:open_timeout],
            timeout: Flickrie.timeout || DEFAULTS[:timeout]
          }
        }
      end

    public

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
        query_params = {oauth_token: token}.merge(params)
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

module Flickrie
  module OAuth
    class RequestToken
      attr_reader :token, :secret

      def initialize(response_body)
        @token = response_body[/(?<=oauth_token=)[^&]+/]
        @secret = response_body[/(?<=oauth_token_secret=)[^&]+/]
      end

      def authorization_url(options = {})
        url = "http://www.flickr.com/services/oauth/authorize?oauth_token=#{token}"
        permissions = options[:permissions] || options[:perms]
        url.concat("&perms=#{permissions}") if permissions
        url
      end
    end

    class Consumer
      def initialize(api_key, shared_secret)
        @api_key, @shared_secret = api_key, shared_secret
      end

      def get_request_token
        connection = Faraday.new "http://www.flickr.com/services/oauth" do |conn|
          conn.request :oauth,
            :consumer_key => @api_key,
            :consumer_secret => @shared_secret
          conn.adapter :net_http
        end

        response = connection.get("request_token") do |req|
          req.params[:oauth_callback] = 'oob'
        end

        RequestToken.new(response.body)
      end

      def get_access_token(oauth_verifier, request_token)
        connection = Faraday.new "http://www.flickr.com/services/oauth" do |conn|
          conn.request :oauth,
            :consumer_key => @api_key,
            :consumer_secret => @shared_secret,
            :token => request_token.token,
            :token_secret => request_token.secret
          conn.adapter :net_http
        end

        response = connection.get "access_token" do |req|
          req.params[:oauth_verifier] = oauth_verifier
        end

        [
          response.body[/(?<=oauth_token=)[^&]+/],
          response.body[/(?<=oauth_token_secret=)[^&]+/]
        ]
      end
    end
  end
end

module Flickrie
  class << self
    def get_authorization_url(options = {})
      @request_token = consumer.get_request_token
      @request_token.authorization_url(options)
    end

    def authorize!(code)
      token, token_secret = consumer.get_access_token(code, @request_token)
    end

    private

    def consumer
      @consumer ||= OAuth::Consumer.new(api_key, shared_secret)
    end
  end
end

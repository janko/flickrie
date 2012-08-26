require 'flickrie/client'
require 'flickrie/upload_client'
require 'flickrie/middleware'
require 'faraday_middleware'

module Flickrie
  module Callable
    # This is for manual use (for example, if I haven't covered something yet, and you really need it).
    # Here's an example:
    #
    #     response = Flickrie.client.get "flickr.photos.getInfo", photo_id: 8423943
    #     response.body['photo']['id']          # => 8423943
    #     response.body['photo']['description'] # => "..."
    #
    #     Flickrie.client.post "flickr.photos.licenses.setLicense", photo_id: 1241497, license_id: 2
    #
    # For the full list of available API methods, see [this page](http://www.flickr.com/services/api/).
    #
    # @return [HTTP response] A Faraday HTTP response
    def client
      params = {
        url: 'http://api.flickr.com/services/rest',
        params: {
          format: 'json',
          nojsoncallback: '1',
          api_key: api_key
        },
        request: {
          open_timeout: open_timeout || DEFAULTS[:open_timeout],
          timeout: timeout || DEFAULTS[:timeout]
        }
      }

      @client ||=
        Client.new(params) do |b|
          b.use Middleware::Retry
          b.use FaradayMiddleware::OAuth,
            consumer_key: api_key,
            consumer_secret: shared_secret,
            token: access_token,
            token_secret: access_secret

          b.use Middleware::FixFlickrData
          b.use Middleware::StatusCheck
          b.use FaradayMiddleware::ParseJson
          b.use Middleware::OAuthCheck

          b.adapter :net_http
        end
    end

    def upload_client
      params = {
        url: 'http://api.flickr.com/services',
        request: {
          open_timeout: open_timeout || DEFAULTS[:open_timeout]
        }
      }

      @upload_client ||=
        UploadClient.new(params) do |b|
          b.use Middleware::Retry
          b.use FaradayMiddleware::OAuth,
            consumer_key: api_key,
            consumer_secret: shared_secret,
            token: access_token,
            token_secret: access_secret
          b.request :multipart

          b.use Middleware::UploadStatusCheck
          b.use FaradayMiddleware::ParseXml
          b.use Middleware::OAuthCheck

          b.adapter :net_http
        end
    end
  end
end

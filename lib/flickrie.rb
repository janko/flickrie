require 'flickrie/client'
require 'flickrie/upload_client'
require 'flickrie/middleware'
require 'faraday_middleware'

module Flickrie
  DEFAULTS = {
    :open_timeout => 3,
    :timeout => 4
  }

  class << self
    # Your API key. If you don't have one already, you can apply for it
    # [here](http://www.flickr.com/services/apps/create/apply) (you first
    # have to sign in).
    attr_accessor :api_key

    # Your shared secret. This goes in pair with your API key.
    # If you don't have the API key already, you can apply for it
    # [here](http://www.flickr.com/services/apps/create/apply) (you first
    # have to sign in).
    attr_accessor :shared_secret

    # Time to wait for the connection to Flickr to open (in seconds).
    # Otherwise `Faraday::Error::TimeoutError` is raised. If you're in a
    # web application, you may want to rescue this exception and display
    # some custom error page (telling the user to try to load the page again,
    # for example).
    #
    # You may want to override this if you notice that your connection often
    # timeouts.
    #
    # Defaults to 3 seconds.
    attr_accessor :open_timeout

    # Time to wait for the first block of response from Flickr to be read
    # (in seconds). Otherwise `Faraday::Error::TimeoutError` is raised.
    # If you're in a web application, you may want to rescue this exception
    # and display some custom error page (telling the user to try to load
    # the page again, for example).
    #
    # You may want to override this if you notice that your connection often
    # timeouts.
    #
    # Defaults to 4 seconds.
    attr_accessor :timeout

    # Access token (token + secret) is used to make authenticated requests.
    # Access tokens are unique for each Flickr user, and they last forever.
    # So, if your app is of that kind that it asks users to authenticate through Flickr,
    # after you get their access token, you can store it somewhere in the database,
    # and you never have to ask that user to authenticate again.
    #
    # You can obtain the access token in various ways:
    #
    # - using this gem's [authentication proccess](https://github.com/janko-m/flickrie#authentication)
    #
    # - using my [flickr_auth](https://github.com/janko-m/flickr_auth) gem
    #
    # - using [omniauth](https://github.com/intridea/omniauth) with the
    #   [omniauth-flickr](https://github.com/timbreitkreutz/omniauth-flickr) strategy
    attr_accessor :access_token, :access_secret

    # If you're in a web application, and you want pagination with
    # [will_paginate](https://github.com/mislav/will_paginate), you can specify it here.
    #
    #     Flickrie.pagination = :will_paginate
    #
    # Now let's assume you have a collection of photos
    #
    #     @photos = Flickrie.photos_from_set(2734243, :per_page => 20, :page => params[:page])
    #
    # This collection is now paginated. You can now call in your ERB template:
    #
    # ```erb
    # <%= will_paginate @photos %>
    # ```
    #
    # If you're using this, be sure to include the 'will_paginate' gem in your
    # `Gemfile`.
    #
    # {Flickrie::Collection} has some basic pagination attributes by itself,
    # these are independent of any pagination library.
    #
    # @see Flickrie::Collection
    attr_accessor :pagination

    [
      :api_key, :shared_secret, :timeout,
      :open_timeout, :access_token, :access_secret
    ].
      each do |attribute|
        define_method "#{attribute}=" do |value|
          instance_variable_set "@#{attribute}", value
          @client = @upload_client = nil
        end
      end

    # This is for manual use (for example, if I haven't covered something yet, and you really need it).
    # Here's an example:
    #
    #     response = Flickrie.client.get "flickr.photos.getInfo", :photo_id => 8423943
    #     response.body['photo']['id']          # => 8423943
    #     response.body['photo']['description'] # => "..."
    #
    #     Flickrie.client.post "flickr.photos.licenses.setLicense", :photo_id => 1241497, :license_id => 2
    #
    # For the full list of available API methods, see [this page](http://www.flickr.com/services/api/).
    #
    # @return [HTTP response] A Faraday HTTP response
    def client
      @client ||= new_client
    end

    # @private
    def new_client(access_token = {})
      params = {
        :url => 'http://api.flickr.com/services/rest',
        :params => {
          :format => 'json',
          :nojsoncallback => '1',
          :api_key => api_key
        },
        :request => {
          :open_timeout => open_timeout || DEFAULTS[:open_timeout],
          :timeout => timeout || DEFAULTS[:timeout]
        }
      }

      Client.new(params) do |b|
        b.use Middleware::Retry
        b.use FaradayMiddleware::OAuth,
          :consumer_key => api_key,
          :consumer_secret => shared_secret,
          :token => access_token[:token] || self.access_token,
          :token_secret => access_token[:secret] || self.access_secret

        b.use Middleware::StatusCheck
        b.use FaradayMiddleware::ParseJson
        b.use Middleware::OAuthCheck

        b.adapter :net_http
      end
    end

    # @private
    def upload_client
      @upload_client ||= new_upload_client
    end

    # @private
    def new_upload_client(access_token = {})
      params = {
        :url => 'http://api.flickr.com/services',
        :request => {
          :open_timeout => open_timeout || DEFAULTS[:open_timeout]
        }
      }

      UploadClient.new(params) do |b|
        b.use Middleware::Retry
        b.use FaradayMiddleware::OAuth,
          :consumer_key => api_key,
          :consumer_secret => shared_secret,
          :token => access_token[:token] || self.access_token,
          :token_secret => access_token[:secret] || self.access_secret
        b.request :multipart

        b.use Middleware::UploadStatusCheck
        b.use FaradayMiddleware::ParseXml
        b.use Middleware::OAuthCheck

        b.adapter :net_http
      end
    end
  end
end

require 'flickrie/api_methods'
require 'flickrie/core_ext'

module Flickrie
  autoload :Collection, 'flickrie/collection'
  autoload :License,    'flickrie/license'
  autoload :User,       'flickrie/user'
  autoload :Media,      'flickrie/media'
  autoload :Photo,      'flickrie/photo'
  autoload :Video,      'flickrie/video'
  autoload :Set,        'flickrie/set'
  autoload :MediaCount, 'flickrie/media_count'
  autoload :Ticket,     'flickrie/ticket'
  autoload :Instance,   'flickrie/instance'
  autoload :OAuth,      'flickrie/oauth'

  extend ApiMethods
end

module Flickr
  class << self
    def client
      @client ||= begin
        client = FaradayStack.build Client,
          :url => 'http://api.flickr.com/services/rest/',
          :params => {
            :format => 'json',
            :nojsoncallback => '1',
            :api_key => self.api_key
          },
          request: {
            :open_timeout => 2,
            :timeout => 3
          }

        client.builder.insert_before FaradayStack::ResponseJSON, StatusCheck
        client
      end
    end
  end

  class Error < StandardError
  end

  class StatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      unless env[:body]['stat'] == 'ok'
        raise Error, env[:body]['message']
      end
    end
  end

  class Client < Faraday::Connection
    def get(method, params)
      super() do |req|
        req.params[:method] = method.to_s
        req.params.update params
      end
    end

    def photos_from_set(photoset_id)
      get 'flickr.photosets.getPhotos', :photoset_id => photoset_id,
        :extras => 'url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o'
    end
  end
end

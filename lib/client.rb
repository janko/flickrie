require 'faraday_stack'

module Flickr
  class << self
    attr_accessor :api_key
  end

  def self.client
    @client ||= begin
      client = FaradayStack.build Client,
        :url => 'http://api.flickr.com/services/rest/',
        :params => {
          :format => 'json',
          :nojsoncallback => '1',
          :api_key => self.api_key
        },
        :request => {
          :open_timeout => 2,
          :timeout => 3
        }

      client.builder.insert_before FaradayStack::ResponseJSON, StatusCheck
      client
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
        req.params.update(params)
      end
    end

    def photos_from_photoset(photoset_id, user_params = {})
      params = {
        :photoset_id => photoset_id,
        :extras => %w[sq q t s n m z c l o].collect { |s| "url_#{s}" }.join(',')
      }
      get 'flickr.photosets.getPhotos', params.update(user_params)
    end

    def photosets_from_user(nsid, user_params = {})
      params = { :user_id => nsid }
      get 'flickr.photosets.getList', params.update(user_params)
    end

    def find_user_by_email(email)
      get 'flickr.people.findByEmail', :find_email => email
    end

    def get_user_info(nsid)
      get 'flickr.people.getInfo', :user_id => nsid
    end
  end
end

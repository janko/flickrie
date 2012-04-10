require 'faraday_stack'
require 'photo'

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
        req.params[:method] = method
        req.params.update(params)
      end
    end

    def photos_from_photoset(photoset_id, user_params = {})
      params = {
        :photoset_id => photoset_id,
        :extras => Photo::SIZES.values.map { |s| "url_#{s}" }.join(',')
      }
      get 'flickr.photosets.getPhotos', params.update(user_params)
    end

    def photosets_from_user(user_id, user_params = {})
      params = { :user_id => user_id }
      get 'flickr.photosets.getList', params.update(user_params)
    end

    def find_user_by_email(email)
      get 'flickr.people.findByEmail', :find_email => email
    end

    def find_user_by_username(username)
      get 'flickr.people.findByUsername', :username => username
    end

    def get_user_info(user_id)
      get 'flickr.people.getInfo', :user_id => user_id
    end

    def get_photoset_info(photoset_id)
      get 'flickr.photosets.getInfo', :photoset_id => photoset_id
    end
    end
  end
end

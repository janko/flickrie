require 'faraday_stack'

module Flickrie
  class << self
    attr_reader :api_key

    def api_key=(api_key)
      @api_key = api_key
      @client = nil
    end

    def client
      @client ||= begin
        client = FaradayStack.build Client,
          :url => 'http://api.flickr.com/services/rest/',
          :params => {
            :format => 'json',
            :nojsoncallback => '1',
            :api_key => self.api_key
          },
          :request => {
            :open_timeout => 5,
            :timeout => 5
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
      if env[:body]['stat'] != 'ok'
        raise Error, env[:body]['message']
      end
    end
  end

  class Client < Faraday::Connection
    def get(method, params = {})
      super() do |req|
        req.params[:method] = method
        req.params.update(params)
      end
    end

    # people
    def find_user_by_email(email)
      get 'flickr.people.findByEmail', :find_email => email
    end

    def find_user_by_username(username)
      get 'flickr.people.findByUsername', :username => username
    end

    def get_user_info(user_nsid)
      get 'flickr.people.getInfo', :user_id => user_nsid
    end

    def public_media_from_user(user_nsid, params = {})
      params = {:user_id => user_nsid}.merge(params)
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      get 'flickr.people.getPublicPhotos', params
    end

    # photos
    def get_media_info(media_id)
      get 'flickr.photos.getInfo', :photo_id => media_id
    end

    def get_media_sizes(media_id)
      get 'flickr.photos.getSizes', :photo_id => media_id
    end

    def search_media(params = {})
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      get 'flickr.photos.search', params
    end

    # licenses
    def get_licenses
      get 'flickr.photos.licenses.getInfo'
    end

    # photosets
    def get_set_info(set_id)
      get 'flickr.photosets.getInfo', :photoset_id => set_id
    end

    def sets_from_user(user_nsid)
      get 'flickr.photosets.getList', :user_id => user_nsid
    end

    def media_from_set(set_id, params = {})
      params = {:photoset_id => set_id}.merge(params)
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      get 'flickr.photosets.getPhotos', params
    end
  end
end

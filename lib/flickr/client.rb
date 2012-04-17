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

  def self.reset_client
    @client = nil
  end

  class Error < StandardError
  end

  class StatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      if env[:body]['stat'] != 'ok'
        Flickr.reset_client if env[:body]['message'] =~ /Invalid API key/i
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

    def items_from_set(set_id, params = {})
      params = {:photoset_id => set_id}.merge(params)
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      get 'flickr.photosets.getPhotos', params
    end

    def get_item_info(item_id)
      get 'flickr.photos.getInfo', :photo_id => item_id
    end

    def public_items_from_user(user_nsid, params = {})
      params = {:user_id => user_nsid}.merge(params)
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      get 'flickr.people.getPublicPhotos', params
    end

    def sets_from_user(user_id)
      get 'flickr.photosets.getList', :user_id => user_id
    def get_item_sizes(item_id)
      get 'flickr.photos.getSizes', :photo_id => item_id
    end

    def find_user_by_email(email)
      get 'flickr.people.findByEmail', :find_email => email
    end

    def find_user_by_username(username)
      get 'flickr.people.findByUsername', :username => username
    end

    def get_user_info(user_nsid)
      get 'flickr.people.getInfo', :user_id => user_nsid
    end

    end

    def get_set_info(set_id)
      get 'flickr.photosets.getInfo', :photoset_id => set_id
    end

    def get_licenses
      get 'flickr.photos.licenses.getInfo'
    end
  end
end

require 'faraday_middleware'

module Flickrie
  class << self
    attr_accessor :api_key, :shared_secret, :timeout, :open_timeout,
      :access_token, :access_secret

    def client(access_token_hash = {})
      @client ||= begin
        client = Client.new(params) do |conn|
          conn.request :oauth,
            :consumer_key => api_key,
            :consumer_secret => shared_secret,
            :token => access_token_hash[:token] || access_token,
            :token_secret => access_token_hash[:secret] || access_secret
          conn.response :json, :content_type => /(text\/plain)|(json)$/
          conn.adapter Faraday.default_adapter
        end

        client.builder.insert_before FaradayMiddleware::ParseJson, StatusCheck
        client
      end
    end

    private

    def params
      {
        :url => 'http://api.flickr.com/services/rest/',
        :params => {
          :format => 'json',
          :nojsoncallback => '1',
          :api_key => api_key
        },
        :request => {
          :open_timeout => open_timeout || 8,
          :timeout => timeout || 8
        }
      }
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

    def post(method, params = {})
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
      get 'flickr.people.getPublicPhotos', ensure_media(params)
    end

    # photos
    def add_media_tags(media_id, tags)
      post 'flickr.photos.addTags', :photo_id => media_id, :tags => tags
    end

    def delete_media(media_id)
      post 'flickr.photos.delete', :photo_id => media_id
    end

    def get_media_info(media_id)
      get 'flickr.photos.getInfo', :photo_id => media_id
    end

    def get_media_sizes(media_id)
      get 'flickr.photos.getSizes', :photo_id => media_id
    end

    def remove_media_tag(tag_id)
      post 'flickr.photos.removeTag', :tag_id => tag_id
    end

    def search_media(params = {})
      get 'flickr.photos.search', ensure_media(params)
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
      get 'flickr.photosets.getPhotos', ensure_media(params)
    end

    private

    def ensure_media(params)
      params[:extras] = [params[:extras], 'media'].compact.join(',')
      params
    end
  end
end

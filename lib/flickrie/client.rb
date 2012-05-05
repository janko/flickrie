require 'faraday_middleware'

module Flickrie
  class << self
    def self.attr_accessor_with_client_reset(*attributes)
      attr_reader *attributes

      attributes.each do |attribute|
        define_method "#{attribute}=" do |value|
          instance_variable_set "@#{attribute}", value
          @client = nil
        end
      end
    end

    attr_accessor_with_client_reset :api_key, :shared_secret,
      :timeout, :open_timeout, :access_token, :access_secret

    def client(access_token_hash = {})
      @client ||= Client.new(params) do |conn|
        conn.request :oauth,
          :consumer_key => api_key,
          :consumer_secret => shared_secret,
          :token => access_token_hash[:token] || access_token,
          :token_secret => access_token_hash[:secret] || access_secret

        conn.use StatusCheck
        conn.response :json, :content_type => /(text\/plain)|(json)$/
        conn.use OAuthStatusCheck

        conn.adapter Faraday.default_adapter
      end
    end

    private

    OPEN_TIMEOUT = 4
    TIMEOUT = 6

    def params
      {
        :url => 'http://api.flickr.com/services/rest',
        :params => {
          :format => 'json',
          :nojsoncallback => '1',
          :api_key => api_key
        },
        :request => {
          :open_timeout => open_timeout || OPEN_TIMEOUT,
          :timeout => timeout || TIMEOUT
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

  class OAuthStatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      if env[:status] != 200
        message = env[:body][/(?<=oauth_problem=)[^&]+/]
        raise Error, message.gsub('_', ' ').capitalize
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

    def media_from_contacts(params = {})
      get 'flickr.photos.getContactsPhotos', ensure_media(params)
    end

    def public_media_from_user_contacts(user_nsid, params = {})
      params = {:user_id => user_nsid}.merge(params)
      get 'flickr.photos.getContactsPublicPhotos', ensure_media(params)
    end

    def get_media_context(media_id)
      get 'flickr.photos.getContext', :photo_id => media_id
    end

    def get_media_counts(params = {})
      get 'flickr.photos.getCounts', params
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

    # photos.upload
    def check_upload_tickets(tickets)
      get 'flickr.photos.upload.checkTickets', :tickets => tickets
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

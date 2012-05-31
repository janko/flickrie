require 'faraday'

module Flickrie
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
    def find_user_by_email(email, params = {})
      get 'flickr.people.findByEmail',
        {:find_email => email}.merge(params)
    end

    def find_user_by_username(username, params = {})
      get 'flickr.people.findByUsername',
        {:username => username}.merge(params)
    end

    def get_user_info(nsid, params = {})
      get 'flickr.people.getInfo',
        {:user_id => nsid}.merge(params)
    end

    def media_from_user(nsid, params = {})
      get 'flickr.people.getPhotos',
        ensure_media({:user_id => nsid}.merge(params))
    end

    def media_of_user(nsid, params = {})
      get 'flickr.people.getPhotosOf',
        ensure_media({:user_id => nsid}.merge(params))
    end

    def public_media_from_user(nsid, params = {})
      get 'flickr.people.getPublicPhotos',
        ensure_media({:user_id => nsid}.merge(params))
    end

    def get_upload_status(params = {})
      get 'flickr.people.getUploadStatus', params
    end

    # photos
    def add_media_tags(media_id, tags, params = {})
      post 'flickr.photos.addTags',
        {:photo_id => media_id, :tags => tags}.merge(params)
    end

    def delete_media(media_id, params = {})
      post 'flickr.photos.delete',
        {:photo_id => media_id}.merge(params)
    end

    def media_from_contacts(params = {})
      get 'flickr.photos.getContactsPhotos', ensure_media(params)
    end

    def public_media_from_user_contacts(nsid, params = {})
      get 'flickr.photos.getContactsPublicPhotos',
        ensure_media({:user_id => nsid}.merge(params))
    end

    def get_media_context(media_id, params = {})
      get 'flickr.photos.getContext',
        {:photo_id => media_id}.merge(params)
    end

    def get_media_counts(params = {})
      get 'flickr.photos.getCounts', params
    end

    def get_media_exif(media_id, params = {})
      get 'flickr.photos.getExif',
        {:photo_id => media_id}.merge(params)
    end

    def get_media_favorites(media_id, params = {})
      get 'flickr.photos.getFavorites',
        {:photo_id => media_id}.merge(params)
    end

    def get_media_info(media_id, params = {})
      get 'flickr.photos.getInfo',
        {:photo_id => media_id}.merge(params)
    end

    def media_not_in_set(params = {})
      get 'flickr.photos.getNotInSet', ensure_media(params)
    end

    def get_media_permissions(media_id, params = {})
      get 'flickr.photos.getPerms',
        {:photo_id => media_id}.merge(params)
    end

    def get_recent_media(params = {})
      get 'flickr.photos.getRecent', ensure_media(params)
    end

    def get_media_sizes(media_id, params = {})
      get 'flickr.photos.getSizes',
        {:photo_id => media_id}.merge(params)
    end

    def remove_media_tag(tag_id, params = {})
      post 'flickr.photos.removeTag',
        {:tag_id => tag_id}.merge(params)
    end

    def search_media(params = {})
      get 'flickr.photos.search', ensure_media(params)
    end

    # photos.upload
    def check_upload_tickets(tickets, params = {})
      get 'flickr.photos.upload.checkTickets',
        {:tickets => tickets}.merge(params)
    end

    # photos.licenses
    def get_licenses(params = {})
      get 'flickr.photos.licenses.getInfo', params
    end

    # photosets
    def get_set_info(set_id, params = {})
      get 'flickr.photosets.getInfo',
        {:photoset_id => set_id}.merge(params)
    end

    def sets_from_user(nsid, params = {})
      get 'flickr.photosets.getList',
        {:user_id => nsid}.merge(params)
    end

    def media_from_set(set_id, params = {})
      get 'flickr.photosets.getPhotos',
        ensure_media({:photoset_id => set_id}.merge(params))
    end

    # test
    def test_login(params = {})
      get 'flickr.test.login', params
    end

    private

    def ensure_media(params)
      params.dup.tap do |dup_params|
        dup_params[:extras] = [dup_params[:extras], 'media'].compact.join(',')
      end
    end
  end
end

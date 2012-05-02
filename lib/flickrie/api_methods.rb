require 'flickrie/client'
require 'flickrie/oauth'
require 'flickrie/license'
require 'flickrie/user'
require 'flickrie/media'
require 'flickrie/photo'
require 'flickrie/video'
require 'flickrie/set'

module Flickrie
  module ApiMethods
    # people
    def find_user_by_email(email)
      response = client.find_user_by_email(email)
      User.from_find(response.body['user'])
    end

    def find_user_by_username(username)
      response = client.find_user_by_username(username)
      User.from_find(response.body['user'])
    end

    def get_user_info(user_nsid)
      response = client.get_user_info(user_nsid)
      User.from_info(response.body['person'])
    end

    def public_media_from_user(user_nsid, params = {})
      response = client.public_media_from_user(user_nsid, params)
      Media.from_user(response.body['photos'])
    end
    def public_photos_from_user(user_nsid, params = {})
      public_media_from_user(user_nsid, params).
        select { |media| media.is_a?(Photo) }
    end
    def public_videos_from_user(user_nsid, params = {})
      public_media_from_user(user_nsid, params).
        select { |media| media.is_a?(Video) }
    end

    # photos
    def add_media_tags(media_id, tags)
      client.add_media_tags(media_id, tags)
    end
    alias add_photo_tags add_media_tags
    alias add_video_tags add_media_tags

    def delete_media(media_id)
      client.delete_media(media_id)
    end
    alias delete_photo delete_media
    alias delete_video delete_media

    def media_from_contacts(params = {})
      response = client.media_from_contacts(params)
      Media.from_contacts(response.body['photos'])
    end
    def photos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Photo) }
    end
    def videos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Video) }
    end

    def get_media_info(media_id)
      response = client.get_media_info(media_id)
      Media.from_info(response.body['photo'])
    end
    alias get_photo_info get_media_info
    alias get_video_info get_media_info

    def get_photo_sizes(photo_id)
      response = client.get_media_sizes(photo_id)
      Photo.from_sizes(response.body['sizes'])
    end
    def get_video_sizes(video_id)
      response = client.get_media_sizes(video_id)
      Video.from_sizes(response.body['sizes'])
    end

    def remove_media_tag(tag_id)
      client.remove_media_tag(tag_id)
    end
    alias remove_photo_tag remove_media_tag
    alias remove_video_tag remove_media_tag

    def search_media(search_params = {})
      response = client.search_media(search_params)
      Media.from_search(response.body['photos'])
    end
    def search_photos(search_params = {})
      search_media(search_params.merge(:media => 'photos'))
    end
    def search_videos(search_params = {})
      search_media(search_params.merge(:media => 'videos'))
    end

    # licenses
    def get_licenses
      response = client.get_licenses
      License.from_hash(response.body['licenses']['license'])
    end

    # photosets
    def get_set_info(set_id)
      response = client.get_set_info(set_id)
      Set.from_info(response.body['photoset'])
    end

    def sets_from_user(user_nsid)
      response = client.sets_from_user(user_nsid)
      Set.from_user(response.body['photosets']['photoset'], user_nsid)
    end

    def media_from_set(set_id, params = {})
      response = client.media_from_set(set_id, params)
      Media.from_set(response.body['photoset'])
    end
    def photos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'photos'))
    end
    def videos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'videos'))
    end
  end
end

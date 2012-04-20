require 'flickr/client'
require 'flickr/license'
require 'flickr/user'
require 'flickr/media'
require 'flickr/photo'
require 'flickr/video'
require 'flickr/set'

module Flickr
  class << self
    def media_from_set(set_id, params = {})
      response = client.media_from_set(set_id, params)
      Media.from_set(response.body['photoset'])
    end
    def photos_from_set(set_id, params = {})
      params = {:media => 'photos', :extras => sizes}.merge(params)
      media_from_set(set_id, params)
    end
    def videos_from_set(set_id, params = {})
      params = {:media => 'videos'}.merge(params)
      media_from_set(set_id, params)
    end

    def get_media_info(media_id)
      response = client.get_media_info(media_id)
      Media.from_info(response.body['photo'])
    end
    alias get_photo_info get_media_info
    alias get_video_info get_media_info

    def public_media_from_user(user_nsid, params = {})
      response = client.public_media_from_user(user_nsid, params)
      Media.from_user(response.body['photos'])
    end
    def public_photos_from_user(user_nsid, params = {})
      params = {:extras => sizes}.merge(params)
      public_media_from_user(user_nsid, params).select do |media|
        media.is_a?(Photo)
      end
    end
    def public_videos_from_user(user_nsid, params = {})
      public_media_from_user(user_nsid, params).select do |media|
        media.is_a?(Video)
      end
    end

    def get_photo_sizes(photo_id)
      response = client.get_media_sizes(photo_id)
      Photo.from_sizes(response.body['sizes'], photo_id)
    end
    def get_video_sizes(video_id)
      response = client.get_media_sizes(video_id)
      Video.from_sizes(response.body['sizes'], video_id)
    end


    def sets_from_user(user_nsid)
      response = client.sets_from_user(user_nsid)
      Set.from_user(response.body['photosets']['photoset'], user_nsid)
    end

    def get_set_info(set_id)
      response = client.get_set_info(set_id)
      Set.new(response.body['photoset'])
    end


    def get_user_info(user_nsid)
      response = client.get_user_info(user_nsid)
      User.from_info(response.body['person'])
    end

    def find_user_by_email(email)
      response = client.find_user_by_email(email)
      User.from_find(response.body['user'])
    end

    def find_user_by_username(username)
      response = client.find_user_by_username(username)
      User.from_find(response.body['user'])
    end


    def get_licenses
      response = client.get_licenses
      License.from_hash(response.body['licenses']['license'])
    end

    private

    def sizes
      Flickr::Photo::SIZES.values.map { |s| "url_#{s}" }.join(',')
    end
  end
end

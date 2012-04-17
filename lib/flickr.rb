require 'flickr/client'
require 'flickr/license'
require 'flickr/user'
require 'flickr/media'
require 'flickr/photo'
require 'flickr/video'
require 'flickr/set'

SIZES = Flickr::Photo::SIZES.values.map { |s| "url_#{s}" }.join(',')

module Flickr
  class << self
    def items_from_set(set_id, params = {})
      response = client.items_from_set(set_id, params)
      response.body['photoset']['photo'].map do |info|
        Media.from_set(info)
      end
    end

    def photos_from_set(set_id, params = {})
      params = {:media => 'photos', :extras => SIZES}.merge(params)
      items_from_set(set_id, params)
    end

    def videos_from_set(set_id, params = {})
      params = {:media => 'videos'}.merge(params)
      items_from_set(set_id, params)
    end

    def get_item_info(item_id)
      response = client.get_item_info(item_id)
      Media.from_info(response.body['photo'])
    end
    alias get_photo_info get_item_info
    alias get_video_info get_item_info

    def public_items_from_user(user_nsid, params = {})
      response = client.public_items_from_user(user_nsid, params)
      response.body['photos']['photo'].map { |info| Media.from_user(info) }
    end

    def public_photos_from_user(user_nsid, params = {})
      params = {:extras => SIZES}.merge(params)
      public_items_from_user(user_nsid, params).select do |item|
        item.is_a?(Photo)
      end
    end

    def public_videos_from_user(user_nsid, params = {})
      public_items_from_user(user_nsid, params).select do |item|
        item.is_a?(Video)
      end
    end

    def get_photo_sizes(photo_id)
      response = client.get_item_sizes(photo_id)
      Photo.from_sizes(response.body['sizes'])
    end

    def get_video_sizes(video_id)
      response = client.get_item_sizes(video_id)
      Video.from_sizes(response.body['sizes'])
    end


    def sets_from_user(user_nsid)
      response = client.sets_from_user(user_nsid)
      response.body['photosets']['photoset'].map { |info| Set.new(info) }
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
      hashes = response.body['licenses']['license']
      hashes.map { |hash| License.new(hash) }
    end
  end
end

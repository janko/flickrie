require 'flickr/client'
require 'flickr/photo'
require 'flickr/video'
require 'flickr/set'
require 'flickr/user'
require 'flickr/license'

module Flickr
  class << self
    def photos_from_set(set_id)
      response = client.photos_from_set(set_id)
      Photo.from_set(response.body['photoset'])
    end

    end

    def videos_from_set(set_id)
      response = client.videos_from_set(set_id)
      Video.from_set(response.body['photoset'])
    end

    def get_item_info(item_id)
      response = client.get_item_info(item_id)
      Media.from_info(response.body['photo'])
    end
    alias get_photo_info get_item_info
    alias get_video_info get_item_info

    def items_from_set(set_id)
      response = client.media_from_set(set_id)
      Media.from_set(response.body['photoset'])
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

    def sets_from_user(user_id)
      response = client.sets_from_user(user_id)
      hashes = response.body['photosets']['photoset']
      hashes.map { |hash| Set.new(hash) }
    def public_videos_from_user(user_nsid, params = {})
      public_items_from_user(user_nsid, params).select do |item|
        item.is_a?(Video)
      end
    end

    def find_user_by_nsid(user_nsid)
      response = client.get_user_info(user_nsid)
      User.from_info(response.body['person'])
    def get_photo_sizes(photo_id)
      response = client.get_item_sizes(photo_id)
      Photo.from_sizes(response.body['sizes'])
    end

    def get_user_nsid(options)
      if options[:email].nil? and options[:username].nil?
        raise ArgumentError, "'email' or 'username' must be present"
      end
    def get_video_sizes(video_id)
      response = client.get_item_sizes(video_id)
      Video.from_sizes(response.body['sizes'])
    end

      if options[:email]
        response = client.find_user_by_email(options[:email])
      else
        response = client.find_user_by_username(options[:username])
      end

      response.body['user']['nsid']
    end

    def find_set_by_id(set_id)
      response = client.get_set_info(set_id)
      Set.new(response.body['photoset'])
    end

    def get_licenses
      response = client.get_licenses
      hashes = response.body['licenses']['license']
      hashes.map { |hash| License.new(hash) }
    end
  end
end

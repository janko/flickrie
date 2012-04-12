require 'objects'
require 'client'

module Flickr
  class << self
    def photos_from_photoset(photoset_id)
      response = client.photos_from_photoset(photoset_id)
      Photo.new_collection(response.body['photoset']['photo'])
    end

    def photosets_from_user(user_id)
      response = client.photosets_from_user(user_id)
      Photoset.new_collection(response.body['photosets']['photoset'])
    end

    def find_user_by_id(user_id)
      response = client.get_user_info(user_id)
      User.new(response.body['person'])
    end

    def get_user_id(options)
      if options[:email].nil? and options[:username].nil?
        raise ArgumentError, "'email' or 'username' must be present"
      end

      response = if options[:email]
                   client.find_user_by_email(options[:email])
                 else
                   client.find_user_by_username(options[:username])
                 end

      response.body['user']['id']
    end

    def find_photoset_by_id(photoset_id)
      response = client.get_photoset_info(photoset_id)
      Photoset.new(response.body['photoset'])
    end
  end
end

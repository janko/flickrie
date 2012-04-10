require 'objects'
require 'client'

module Flickr
  class << self
    def photos_from_photoset(photoset_id, user_params = {})
      response = client.photos_from_photoset(photoset_id)
      Photo.new_collection(response.body['photoset']['photo'])
    end

    def photosets_from_user(user_id, user_params = {})
      response = client.photosets_from_user(user_id)
      Photoset.new_collection(response.body['photosets']['photoset'])
    end

    def find_user_by_email(email)
      response = client.find_user_by_email(email)
      response = client.get_user_info(response.body['user']['nsid'])
      User.new(response.body['person'])
    end

    def find_user_by_username(username)
      response = client.find_user_by_username(email)
      response = client.get_user_info(response.body['user']['nsid'])
      user.new(response.body['person'])
    end

    def get_user_info(user_id)
      response = client.get_user_info(user_id)
      User.new(response.body['user'])
    end
  end
end

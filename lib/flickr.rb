require 'client'
require 'objects'

module Flickr
  class << self
    def photos_from_set(set_id)
      response = client.photos_from_set(set_id)
      response.body['photoset']['photo'].map do |hash|
        Photo.new(hash)
      end

    def photosets_from_user(nsid)
      response = client.photosets_from_user(nsid)
      Photoset.new_collection(response.body['photosets']['photoset'])
    end
    end
  end
end

module Flickr
  class << self
    def photos_from_set(set_id)
      response = client.photos_from_set(set_id)
      response.body['photoset']['photo'].map do |hash|
        Photo.new(hash)
      end
    end
  end
end

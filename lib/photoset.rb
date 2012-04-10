require 'object'

module Flickr
  class Photoset < Flickr::Object
    def initialize(hash)
      @hash = hash
    end

    def id
      @hash['id']
    end

    def photos_count
      @hash['photos']
    end
  end
end

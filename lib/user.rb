require 'object'

module Flickr
  class User < Flickr::Object
    def id
      @hash['id']
    end

    def nsid
      @hash['nsid']
    end

    def username
      @hash['username']['_content']
    end

    def real_name
      @hash['realname']['_content']
    end

    def location
      @hash['location']['_content']
    end

    def description
      @hash['description']['_content']
    end

    def profile_url
      @hash['profileurl']['_content']
    end

    def mobile_url
      @hash['mobileurl']['_content']
    end

    def pro?
      @hash['ispro'].to_i == 1
    end

    def photos_url
      @hash['photosurl']['_content']
    end

    def photos_count
      @hash['photos']['count']['_content']
    end

    def first_photo_taken
      @hash['photos']['firstdatetaken']['_content']
    end

    def flickr_hash
      @hash
    end

    private

    def initialize(hash)
      @hash = hash
    end
  end
end

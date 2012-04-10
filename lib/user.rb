require 'object'
require 'date'

module Flickr
  class User < Flickr::Object
    def id
      @hash['id']
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

    def first_photo_upload
      DateTime.parse(@hash['photos']['firstdatetaken']['_content']).to_time
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

__END__

{
  'id' => '67131352@N04',
  'nsid' => '67131352@N04',
  'ispro' => 0,
  'iconserver' => '0',
  'iconfarm' => 0,
  'path_alias' => nil,
  'username' => {'_content' => 'Janko Marohnić'},
  'realname' => {'_content' => ''},
  'location' => {'_content' => ''},
  'description' => {'_content' => ''},
  'photosurl' => {'_content' => 'http://www.flickr.com/photos/67131352@N04/'},
  'profileurl' => {'_content' => 'http://www.flickr.com/people/67131352@N04/'},
  'mobileurl' => {'_content' => 'http://m.flickr.com/photostream.gne?id=67099213'},
  'photos' => {
    'firstdatetaken' => {'_content' => '2011-06-21 21:43:09'},
    'firstdate' => {'_content' => '1333954416'},
    'count' => {'_content' => 2}
  }
}

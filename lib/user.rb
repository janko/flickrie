require 'object'
require 'date'

module Flickr
  class User < Flickr::Object
    attr_reader :id, :nsid, :username, :real_name, :location,
      :description, :profile_url, :mobile_url, :photos_url,
      :photos_count, :first_photo_upload, :path_alias, :buddy_icon_url

    def pro?
      @pro
    end

    private

    def initialize(info)
      @id = info['id']
      @nsid = info['nsid']
      @username = info['username']['_content']
      @real_name = info['realname']['_content']
      @location = info['location']['_content']
      @description = info['description']['_content']
      @profile_url = info['profileurl']['_content']
      @mobile_url = info['mobileurl']['_content']
      @photos_url = info['photosurl']['_content']
      @photos_count = info['photos']['count']['_content'].to_i
      @first_photo_upload = DateTime.parse(@info['photos']['firstdatetaken']['_content']).to_time
      @pro = (info['ispro'].to_i == 1)
      @path_alias = info['path_alias']
      @buddy_icon_url =
        if info['iconserver'].to_i > 0
          icon_farm, icon_server = info['iconfarm'], info['iconserver']
          "http://farm{#{icon_farm}}.staticflickr.com/{#{icon_server}}/buddyicons/#{@nsid}.jpg"
        else
          "http://www.flickr.com/images/buddyicon.jpg"
        end
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

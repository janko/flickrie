# encoding: utf-8

require 'test/unit'
require 'user'

class UserTest < Test::Unit::TestCase
  include Flickr

  def User.public_new(*args)
    new(*args)
  end

  def setup
    @hash = {
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
  end

  def test_attributes
    attributes = [:id, :username, :real_name, :location, :description,
                  :profile_url, :mobile_url, :pro?, :photos_url,
                  :photos_count, :first_photo_taken, :flickr_hash]
    user = User.public_new(@hash)
    assert_nothing_raised do
      attributes.each do |attribute|
        user.send(attribute) if user.methods.include?(attribute)
      end
    end
  end
end

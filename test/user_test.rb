# encoding: utf-8

require 'test/unit'
require 'user'
require 'date'

class UserTest < Test::Unit::TestCase
  include Flickr

  def User.public_new(*args)
    new(*args)
  end

  HASH = {
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

  def test_attributes
    user = User.public_new(HASH)

    assert_equal '67131352@N04', user.id
    assert_equal false, user.pro?
    assert_equal 'Janko Marohnić', user.username
    assert_equal '', user.real_name
    assert_equal '', user.location
    assert_equal '', user.description
    assert_equal 'http://www.flickr.com/photos/67131352@N04/', user.photos_url
    assert_equal 'http://www.flickr.com/people/67131352@N04/', user.profile_url
    assert_equal 'http://m.flickr.com/photostream.gne?id=67099213', user.mobile_url
    assert_equal 2, user.photos_count
    assert_equal DateTime.parse('2011-06-21 21:43:09').to_time, user.first_photo_upload
    assert_equal HASH, user.flickr_hash
  end
end

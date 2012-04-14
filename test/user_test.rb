# encoding: utf-8
require 'test/unit'
require 'flickr/user'

class UserTest < Test::Unit::TestCase
  Flickr::User.instance_eval do
    def public_from_info(*args)
      from_info(*args)
    end
  end

  def test_attributes
    info_hash = {
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
    user = Flickr::User.public_from_info(info_hash)

    assert_equal '67131352@N04', user.id
    assert_equal '67131352@N04', user.nsid
    assert_equal false, user.pro?
    assert_equal false, user.buddy_icon_url.empty?
    assert_nil user.path_alias
    assert_equal 'Janko Marohnić', user.username
    assert_equal '', user.real_name
    assert_equal '', user.location
    assert_equal '', user.description
    assert_equal false, user.photos_url.empty?
    assert_equal false, user.profile_url.empty?
    assert_equal false, user.mobile_url.empty?
    assert_equal 2, user.photos_count
    assert_instance_of Time, user.first_uploaded
    assert_instance_of Time, user.first_taken
  end
end

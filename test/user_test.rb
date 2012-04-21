# encoding: utf-8
require 'test/unit'
require 'flickrie'

class UserTest < Test::Unit::TestCase
  def setup
    Flickrie.api_key = ENV['FLICKR_API_KEY']
    @user_nsid = '67131352@N04'
  end

  def test_get_user_info
    user = Flickrie.get_user_info(@user_nsid)

    assert_equal @user_nsid, user.id
    assert_equal @user_nsid, user.nsid
    assert_equal 'Janko Marohnić', user.username
    assert_equal 'Janko Marohnić', user.real_name
    assert_equal 'Zagreb, Croatia', user.location
    assert_equal 'Sarajevo, Skopje, Warsaw, Zagreb', user.time_zone['label']
    assert_equal '+01:00', user.time_zone['offset']
    assert_equal <<-DESCRIPTION.chomp, user.description
I'm a programmer, and I'm gonna program a badass Ruby library for Flickr.
    DESCRIPTION

    refute user.profile_url.empty?
    refute user.mobile_url.empty?
    refute user.photos_url.empty?

    assert_equal '5464', user.icon_server
    assert_equal 6, user.icon_farm
    refute user.buddy_icon_url.empty?

    assert_equal false, user.pro?

    assert_instance_of Time, user.first_taken
    assert_instance_of Time, user.first_uploaded

    assert_equal 99, user.media_count
  end

  def test_find_user_by_username_or_email
    user = Flickrie.find_user_by_username('Janko Marohnić')

    assert_equal @user_nsid, user.id
    assert_equal @user_nsid, user.nsid
    assert_equal 'Janko Marohnić', user.username

    user = Flickrie.find_user_by_email('janko.marohnic@gmail.com')

    assert_equal @user_nsid, user.id
    assert_equal @user_nsid, user.nsid
    assert_equal 'Janko Marohnić', user.username
  end
end

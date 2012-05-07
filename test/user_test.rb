# encoding: utf-8
require 'test_helper'

Flickrie::User.instance_eval do
  def public_new(*args)
    new(*args)
  end
end

class UserTest < Test::Unit::TestCase
  def setup
    @user_nsid = '67131352@N04'
  end

  def test_square_brackets
    VCR.use_cassette 'user/square_brackets' do
      user = Flickrie.get_user_info(@user_nsid)
      assert_equal user['nsid'], user.nsid
    end
  end

  def test_get_info
    VCR.use_cassette 'user/get_info' do
      [Flickrie.get_user_info(@user_nsid),
       Flickrie::User.public_new('nsid' => @user_nsid).get_info].
        each do |user|
          assert_equal @user_nsid, user.id
          assert_equal @user_nsid, user.nsid
          assert_equal 'Janko Marohnić', user.username
          assert_equal 'Janko Marohnić', user.real_name
          assert_equal 'Zagreb, Croatia', user.location
          assert_equal 'Sarajevo, Skopje, Warsaw, Zagreb', user.time_zone['label']
          assert_equal '+01:00', user.time_zone['offset']
          assert_equal <<-DESCRIPTION.chomp.lstrip, user.description
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

          assert_equal 98, user.media_count
        end
    end
  end

  def test_find_by_username_or_email
    VCR.use_cassette 'user/find_by_email_or_username' do
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
end

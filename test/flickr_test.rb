# encoding: utf-8
require 'test/unit'
require 'flickr'

class FlickrTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV["FLICKR_API_KEY"]
  end

  def test_methods_not_raising_an_error
    assert_nothing_raised do
      Flickr.photos_from_set('72157629409394888')
      Flickr.sets_from_user('67131352@N04')
      Flickr.find_user_by_email('janko.marohnic@gmail.com')
      Flickr.find_user_by_username('Janko Marohnić')
      Flickr.find_user_by_id('67131352@N04')
      Flickr.find_set_by_id(Flickr.sets_from_user('67131352@N04').first.id)
    end
  end
end

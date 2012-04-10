# encoding: utf-8
require 'test/unit'
require 'client'

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_api_key
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
  end

  def test_methods_not_raising_an_exception
    assert_nothing_raised(Flickr::Error) do
      client = Flickr.client
      client.photos_from_photoset('72157629409394888')
      client.photosets_from_user('67131352@N04')
      client.find_user_by_email('janko.marohnic@gmail.com')
      client.find_user_by_username('Janko Marohnić')
      client.get_user_info('67131352@N04')
    end
  end
end

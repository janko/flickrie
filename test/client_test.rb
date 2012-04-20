# encoding: utf-8
require 'test/unit'
require 'flickr/client'

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
    @client = Flickr.client
    @set_id = 72157629851991663
    @media_id = 7093038981
    @user_nsid = '67131352@N04'
  end

  def test_internals
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
    assert_instance_of Flickr::Client, @client
  end

  def test_api_calls
    assert_nothing_raised do
      # people
      @client.find_user_by_email('janko.marohnic@gmail.com')
      @client.find_user_by_username('Janko Marohnić')
      @client.get_user_info(@user_nsid)
      @client.public_media_from_user(@user_nsid)

      # photos
      @client.get_media_info(@media_id)
      @client.get_media_sizes(@media_id)
      @client.search_media(:user_id => @user_nsid)

      # licenses
      @client.get_licenses

      # photosets
      @client.get_set_info(@set_id)
      @client.sets_from_user(@user_nsid)
      @client.media_from_set(@set_id)
    end
  end
end

# encoding: utf-8
require 'test/unit'
require 'flickr/client'

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
    @client = Flickr.client
  end

  def test_internals
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
    assert_instance_of Flickr::Client, @client
  end

  def test_api_calls
    set_id = 72157629409394888
    item_id = 6913731566
    user_nsid = '67131352@N04'

    assert_nothing_raised do
      @client.items_from_set(set_id)
      @client.get_item_info(item_id)
      @client.public_items_from_user(user_nsid)
      @client.get_item_sizes(item_id)

      @client.find_user_by_email('janko.marohnic@gmail.com')
      @client.find_user_by_username('Janko Marohnić')
      @client.get_user_info(user_nsid)

      @client.sets_from_user(user_nsid)
      @client.get_set_info(set_id)
      @client.get_licenses
    end
  end
end

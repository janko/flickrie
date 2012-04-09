require 'test/unit'
require 'flickr/client'

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_api_key
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
  end

  def test_photos_from_set
    photoset_id = '72157629409394888'
    assert_nothing_raised { Flickr.client.photos_from_set(photoset_id.to_i).body['photoset']['id'] }
    assert_equal photoset_id, Flickr.client.photos_from_set(photoset_id).body['photoset']['id']
    assert Flickr.client.photos_from_set(photoset_id).body['photoset']['photo'].is_a?(Array)
  end
end

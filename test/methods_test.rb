require 'flickr'
require 'test/unit'

class MethodsTest < Test::Unit::TestCase
  def test_photos_from_set
    Flickr.api_key = ENV["FLICKR_API_KEY"]
    assert_equal 2, Flickr.photos_from_set(72157629409394888).count
  end
end

require 'test/unit'
require 'flickr'

class FlickrTest < Test::Unit::TestCase
  def test_photos_from_set
    Flickr.api_key = ENV["FLICKR_API_KEY"]
    Flickr.photos_from_photoset(72157629409394888).each do |photo|
      assert photo.instance_of?(Flickr::Photo), %q(Flickr.photos_from_set doesn't return instances of Flickr::Photo)
      Flickr.find_user_by_username('Janko Marohnić')
    end
  end
end

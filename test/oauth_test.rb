require 'test/unit'
require 'flickrie'

class OAuthTest < Test::Unit::TestCase
  def setup
    @photo_id = 6946979188
    Flickrie.api_key = ENV['FLICKR_API_KEY']
    Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
    Flickrie.token = ENV['FLICKR_TOKEN']
    Flickrie.token_secret = ENV['FLICKR_TOKEN_SECRET']
  end

  def test_permissions
    assert_nothing_raised do
      Flickrie.client.get "flickr.photos.getPerms", :photo_id => @photo_id
      Flickrie.client.post "flickr.photos.setSafetyLevel", :photo_id => @photo_id, :safety_level => 1
    end
    assert_raises(Flickrie::Error) do
      Flickrie.client.get "flickr.photos.delete", :photo_id => @photo_id
    end
  end
end

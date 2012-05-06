require 'test/unit'
require 'flickrie'

class InstanceTest < Test::Unit::TestCase
  def test_if_it_works
    VCR.use_cassette 'instance/only' do
      Flickrie.api_key = ENV['FLICKR_API_KEY']
      Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']

      flickr = Flickrie::Instance.new \
        ENV['FLICKR_ACCESS_TOKEN'], ENV['FLICKR_ACCESS_SECRET']

      photo_id = 6946979188
      flickr.add_photo_tags(photo_id, "janko")
      photo = flickr.get_photo_info(photo_id)

      tag = photo.tags.find { |tag| tag.content == "janko" }
      assert_not_nil tag

      flickr.remove_photo_tag tag.id
    end
  end
end

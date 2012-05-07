class InstanceTest < Test::Unit::TestCase
  def test_calling_api_methods
    VCR.use_cassette 'instance/calling_api_methods' do
      Flickrie.access_token = nil
      Flickrie.access_secret = nil

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

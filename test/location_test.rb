require 'test_helper'

class LocationTest < Test::Unit::TestCase
  def setup
    @media_id = 6946979188
  end

  def test_attributes_returning_nil
    location = Flickrie::Location.new

    assert_nil location.latitude
    assert_nil location.longitude
    assert_nil location.accuracy
    assert_nil location.context
    assert_nil location.place_id
    assert_nil location.woeid

    assert_nil location.neighbourhood
    assert_nil location.locality
    assert_nil location.county
    assert_nil location.region
    assert_nil location.country
  end

  def test_square_brackets
    VCR.use_cassette 'location/square_brackets' do
      media = Flickrie.get_media_info(@media_id)
      assert_equal media.location['woeid'], media.location.woeid
    end
  end
end

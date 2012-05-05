require 'test'

class LocationTest < Test::Unit::TestCase
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
end

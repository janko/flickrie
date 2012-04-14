require 'test/unit'
require 'flickr/license'
require 'flickr/client'

class LicenseTest < Test::Unit::TestCase
  Flickr::License.instance_eval do
    def public_response_array
      response_array
    end
  end

  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_licenses_staying_the_same
    licenses_array = Flickr.client.get_licenses.body['licenses']['license']
    assert_equal licenses_array.sort_by { |hash| hash['id'] }, Flickr::License.public_response_array
  end
end

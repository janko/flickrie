require 'test'

Flickrie::License.instance_eval do
  def public_response_array
    response_array
  end
end

class LicenseTest < Test::Unit::TestCase
  def test_get_licenses
    VCR.use_cassette 'license/get_licenses' do
      licenses = Flickrie.get_licenses

      licenses.each do |license|
        assert_includes ('0'..'8'), license.id
        assert_instance_of String, license.name
        assert_instance_of String, license.url
      end
    end
  end
end

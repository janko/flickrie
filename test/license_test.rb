require 'test'
require 'flickrie'

Flickrie::License.instance_eval do
  def public_response_array
    response_array
  end
end

class LicenseTest < Test::Unit::TestCase
  def test_licenses_staying_the_same
    licenses_array = Flickrie.client.get_licenses.body['licenses']['license']
    assert_equal licenses_array.sort_by { |hash| hash['id'] },
      Flickrie::License.public_response_array
  end

  def test_get_licenses
    licenses = Flickrie.get_licenses

    licenses.each do |license|
      assert_includes ('0'..'8'), license.id
      assert_instance_of String, license.name
      assert_instance_of String, license.url
    end
  end
end

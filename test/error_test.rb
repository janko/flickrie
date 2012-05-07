class ErrorTest < Test::Unit::TestCase
  def test_code
    VCR.use_cassette 'error/code' do
      begin
        Flickrie.api_key = nil
        Flickrie.client.get_licenses
      rescue Flickrie::Error => error
        assert_equal 100, error.code
      end

      begin
        Flickrie.api_key = nil
        Flickrie.upload_client.upload \
          File.expand_path(File.join(File.dirname(__FILE__), 'photo.jpg'))
      rescue Flickrie::Error => error
        assert_equal 100, error.code
      end
    end
  end
end

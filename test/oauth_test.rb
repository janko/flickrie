require 'test_helper'

class OAuthTest < Test::Unit::TestCase
  def test_raising_errors
    VCR.use_cassette 'oauth/tokens' do
      Flickrie.api_key = "foo"
      Flickrie.shared_secret = "foo"

      assert_raises(Flickrie::OAuth::Error) do
        Flickrie::OAuth.get_request_token
      end

      Flickrie.api_key = ENV['FLICKR_API_KEY']
      assert_raises(Flickrie::OAuth::Error) do
        Flickrie::OAuth.get_request_token
      end

      Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
      assert_nothing_raised { Flickrie::OAuth.get_request_token }

      request_token = Flickrie::OAuth.get_request_token
      assert_raises(Flickrie::OAuth::Error) do
        Flickrie::OAuth.get_access_token("foo", request_token)
      end
    end
  end
end

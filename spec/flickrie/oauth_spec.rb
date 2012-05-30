require 'spec_helper'

describe :OAuth do
  context "incorrect credentials", :vcr do
    it "raises exceptions" do
      Flickrie.api_key = "foo"
      Flickrie.shared_secret = "foo"

      expect { Flickrie::OAuth.get_request_token }.to raise_error(Flickrie::Error)

      Flickrie.api_key = ENV['FLICKR_API_KEY']
      expect { Flickrie::OAuth.get_request_token }.to raise_error(Flickrie::Error)

      Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
      expect { Flickrie::OAuth.get_request_token }.to_not raise_error(Flickrie::Error)

      request_token = Flickrie::OAuth.get_request_token
      request_token.authorize_url.should_not be_empty
      request_token.get_authorization_url.should_not be_empty

      expect { Flickrie::OAuth.get_access_token("foo", request_token) }.to raise_error(Flickrie::Error)
      expect { request_token.get_access_token("foo") }.to raise_error(Flickrie::Error)
    end
  end
end

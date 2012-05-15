require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Flickrie::OAuth do
  context "incorrect credentials" do
    it "should raise exceptions", :vcr do
      Flickrie.api_key = "foo"
      Flickrie.shared_secret = "foo"

      expect { Flickrie::OAuth.get_request_token }.
        to raise_error(Flickrie::OAuth::Error)

      Flickrie.api_key = ENV['FLICKR_API_KEY']
      expect { Flickrie::OAuth.get_request_token }.
        to raise_error(Flickrie::OAuth::Error)

      Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
      request_token = Flickrie::OAuth.get_request_token
      expect { Flickrie::OAuth.get_access_token("foo", request_token) }.
        to raise_error(Flickrie::OAuth::Error)
    end
  end
end

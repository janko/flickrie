require 'spec_helper'

describe :Flickrie do
  context "a new credential is filled in" do
    it "should reset the client", :vcr do
      Flickrie.api_key = nil
      expect { Flickrie.get_licenses }.to raise_error(Flickrie::Error)
      expect { Flickrie.upload(PHOTO_PATH) }.to raise_error(Flickrie::Error)
    end
  end

  it "should have all methods written down", :vcr do
    my_methods = Flickrie::FLICKR_API_METHODS.keys
    flickr_methods = Flickrie.get_methods

    (flickr_methods - my_methods).should be_empty
  end
end

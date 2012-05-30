require 'spec_helper'

describe :Flickrie do
  context "a new credential is filled in" do
    it "should reset the client", :vcr do
      Flickrie.api_key = nil
      expect { Flickrie.get_licenses }.to raise_error(Flickrie::Error)
      expect { Flickrie.upload(PHOTO_PATH) }.to raise_error(Flickrie::Error)
      Flickrie.api_key = ENV['FLICKR_API_KEY']
      expect { Flickrie.get_licenses }.to_not raise_error(Flickrie::Error)
      expect { Flickrie.upload(PHOTO_PATH) }.to_not raise_error(Flickrie::Error)

      photo = Flickrie.photos_from_user(USER_NSID).find { |photo| photo.title == "photo" }
      Flickrie.delete_photo(photo.id)
    end
  end
end

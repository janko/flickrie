require 'spec_helper'

describe :Error do
  context "a request was made and failed", :vcr do
    it "is raised" do
      Flickrie.api_key = nil
      expect { Flickrie.get_licenses }.to raise_error(Flickrie::Error)
      expect { Flickrie.upload(PHOTO_PATH) }.to raise_error(Flickrie::Error)
    end

    it "has #code attribute present" do
      Flickrie.api_key = nil
      begin
        Flickrie.get_licenses
      rescue => exception
        exception.code.should eq(100)
      end

      begin
        Flickrie.upload(PHOTO_PATH)
      rescue => exception
        exception.code.should eq(100)
      end
    end
  end
end

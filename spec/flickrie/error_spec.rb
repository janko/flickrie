require 'spec_helper'

describe Flickrie::Error do
  context "a request was made and failed" do
    it "should be raised", :vcr do
      Flickrie.api_key = nil
      expect { Flickrie.get_licenses }.to raise_error(described_class)
      expect { Flickrie.upload(PHOTO_PATH) }.to raise_error(described_class)
    end

    it "should have #code attribute present", :vcr do
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

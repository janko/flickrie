describe Flickrie::Error do
  before(:all) do
    Flickrie.api_key = nil
  end

  context "was raised" do
    use_vcr_cassette "error/was_raised"

    it "should be raised when the request failed" do
      expect { Flickrie.get_licenses }.to raise_error(described_class)
      expect { Flickrie.upload(PHOTO_PATH) }.to raise_error(described_class)
    end
  end

  context "code" do
    use_vcr_cassette "error/code"

    it "should have #code attribute present" do
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

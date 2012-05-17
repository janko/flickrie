require 'spec_helper'

describe Flickrie::Video do
  context "get info" do
    it "should have all attributes correctly set", :vcr do
      video = Flickrie.get_video_info(VIDEO_ID)

      video.ready?.should be_true
      video.failed?.should be_false
      video.pending?.should be_false

      video.duration.should eq(16)
      video.width.should eq(352)
      video.height.should eq(288)

      video.source_url.should be_nil
      video.download_url.should be_nil
      video.mobile_download_url.should be_nil
    end
  end

  context "get sizes" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.get_video_sizes(VIDEO_ID),
        Flickrie::Video.public_new('id' => VIDEO_ID).get_sizes
      ].
        each do |video|
          video.can_download?.should be_true
          video.can_blog?.should be_false
          video.can_blog?.should be_false

          video.source_url.should_not be_empty
          video.download_url.should_not be_empty
          video.mobile_download_url.should_not be_empty
        end
    end
  end

  context "blank" do
    it "should have attributes equal to nil" do
      video = Flickrie::Video.public_new
      [
        :ready?, :failed?, :pending?, :duration, :width, :height,
        :source_url, :download_url, :mobile_download_url
      ].
        each do |attribute|
          video.send(attribute).should be_nil
        end
    end
  end
end

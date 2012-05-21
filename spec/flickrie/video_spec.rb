require 'spec_helper'

describe Flickrie::Video do
  context "get info" do
    it "should have all attributes correctly set", :vcr do
      video = Flickrie.get_video_info(VIDEO_ID)

      video.ready?.should be_true
      video.failed?.should be_false
      video.pending?.should be_false

      video.duration.should == 16
      video.width.should == 352
      video.height.should == 288

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
          [:can_download?, :can_blog?, :can_print?].each do |attribute|
            video.send(attribute).should be_a_boolean
          end

          video.source_url.should_not be_empty
          video.download_url.should_not be_empty
          video.mobile_download_url.should_not be_empty
        end
    end
  end

  context "blank" do
    it "should have attributes equal to nil" do
      attributes = Flickrie::Video.instance_methods -
        Flickrie::Media.instance_methods -
        Object.instance_methods -
        [:get_info, :get_sizes, :[]]
      video = Flickrie::Video.public_new
      attributes.each do |attribute|
        video.send(attribute).should be_nil
      end
    end
  end
end

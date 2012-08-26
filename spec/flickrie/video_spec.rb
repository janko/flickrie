require 'spec_helper'

describe :Video do
  before(:all) do
    @attributes = {
      :ready? => true,
      :failed? => false,
      :pending? => false,

      duration: 16,
      width: 352,
      height: 288
    }
  end

  context "get info", :vcr do
    let(:video) { Flickrie.get_video_info(VIDEO_ID) }

    it "has correct attributes" do
      @attributes.keys.each do |attribute|
        video.send(attribute).should correspond_to(@attributes[attribute])
      end

      [:source_url, :download_url, :mobile_download_url].each do |attribute|
        video.send(attribute).should be_nil
      end
    end
  end

  context "get sizes", :vcr do
    let(:videos) {
      [
        Flickrie.get_video_sizes(VIDEO_ID),
        Flickrie::Video.public_new('id' => VIDEO_ID).get_sizes
      ]
    }

    it "has correct attributes" do
      videos.each do |video|
        [:can_download?, :can_blog?, :can_print?].each do |attribute|
          video.send(attribute).should be_a_boolean
        end

      [:source_url, :download_url, :mobile_download_url].each do |attribute|
        video.send(attribute).should_not be_empty
      end
      end
    end
  end

  context "blank" do
    let(:video) { Flickrie::Video.public_new({}) }

    it "should have attributes equal to nil" do
      attributes = Flickrie::Video.instance_methods -
        Flickrie::Media.instance_methods -
        Object.instance_methods -
        [:get_info, :get_sizes, :[]]

      attributes.each do |attribute|
        video.send(attribute).should be_nil
      end
    end
  end
end

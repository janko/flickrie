# encoding: utf-8
require File.expand_path("../../spec_helper", __FILE__)

describe Flickrie::Set do
  before(:all) do
    @attributes = {
      :id => SET_ID,
      :secret => '25bb44852b',
      :server => '7049',
      :farm => 8,
      :title => 'Speleologija',
      :description => 'Slike sa škole speleologije Velebit.',
      :primary_media_id => PHOTO_ID,
      :primary_photo_id => PHOTO_ID,
      :primary_video_id => PHOTO_ID,
      :views_count => 0,
      :comments_count => 0,
      :photos_count => 97,
      :videos_count => 1,
      :media_count => 98,
      :owner => {
        :nsid => USER_NSID
      },
      :can_comment? => false,
    }
  end

  def test_common_attributes(set)
    @attributes.keys.each do |attribute|
      test_recursively(set, attribute)
    end

    set.photos.all? { |photo| photo.is_a?(Flickrie::Photo) }.should be_true
    set.videos.all? { |video| video.is_a?(Flickrie::Video) }.should be_true
    set.media.all? do |media|
      media.is_a?(Flickrie::Photo) or media.is_a?(Flickrie::Video)
    end.should be_true

    set.created_at.should be_an_instance_of(Time)
    set.updated_at.should be_an_instance_of(Time)

    set.url.should_not be_empty
  end

  context "get info" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.get_set_info(SET_ID),
        Flickrie::Set.public_new('id' => SET_ID).get_info
      ].
        each do |set|
          test_common_attributes(set)
        end
    end
  end

  context "from user" do
    it "should have all attributes correctly set", :vcr do
      set = Flickrie.sets_from_user(USER_NSID).find { |set| set.id == SET_ID }
      test_common_attributes(set)
      set.needs_interstitial?.should be_false
      set.visibility_can_see_set?.should be_true
    end
  end
end

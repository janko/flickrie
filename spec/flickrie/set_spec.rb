# encoding: utf-8
require 'spec_helper'

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
      :comments_count => 0,
      :photos_count => 97,
      :videos_count => 1,
      :media_count => 98,
      :owner => {
        :nsid => USER_NSID
      }
    }
  end

  def test_common_attributes(set)
    @attributes.keys.each do |attribute|
      set.send(attribute).should correspond_to(@attributes[attribute])
    end

    set.photos.each { |object| object.should be_a_photo }
    set.videos.each { |object| object.should be_a_video }
    set.media.each  { |object| object.should be_a_media }

    # Time
    set.created_at.should be_an_instance_of(Time)
    set.updated_at.should be_an_instance_of(Time)

    # Other
    set.url.should_not be_empty
    set.views_count.should be_a_number
    set.can_comment?.should be_a_boolean
  end

  context "get info" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.get_set_info(SET_ID),
        Flickrie::Set.public_new('id' => SET_ID).get_info
      ].
        each { |set| test_common_attributes(set) }
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

  context "blank set" do
    it "should have all attributes equal to nil" do
      attributes = Flickrie::Set.instance_methods -
        Object.instance_methods -
        [:photos, :videos, :media, :[], :get_info]
      set = Flickrie::Set.public_new

      attributes.each do |attribute|
        set.send(attribute).should be_nil
      end
    end
  end
end

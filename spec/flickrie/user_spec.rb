require 'spec_helper'

describe Flickrie::User do
  before(:all) do
    @attributes = {
      :id => USER_NSID,
      :nsid => USER_NSID,
      :username => USER_USERNAME,
      :real_name => USER_USERNAME,
      :location => "Zagreb, Croatia",
      :time_zone => {
        :label => "Sarajevo, Skopje, Warsaw, Zagreb",
        :offset => "+01:00"
      },
      :description => "I'm a programmer, and I'm gonna program a badass Ruby library for Flickr.",
      :icon_server => "5464",
      :icon_farm => 6,
      :pro? => false,
      :media_count => 98
    }
  end

  context "get info" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.get_user_info(USER_NSID),
        Flickrie::User.public_new('nsid' => USER_NSID).get_info
      ].
        each do |user|
          @attributes.keys.each do |attribute|
            user.send(attribute).should correspond_to(@attributes[attribute])
          end

          [:profile_url, :mobile_url, :photos_url, :buddy_icon_url].each do |attribute|
            user.send(attribute).should_not be_empty
          end

          [:first_taken, :first_uploaded].each do |time_attribute|
            user.send(time_attribute).should be_an_instance_of(Time)
          end
        end
    end
  end

  context "find by username or email" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.find_user_by_username(USER_USERNAME),
        Flickrie.find_user_by_email(USER_EMAIL)
      ].
        each do |user|
          user.id.should == USER_NSID
          user.nsid.should == USER_NSID
          user.username.should == USER_USERNAME
        end
    end
  end

  context "getting media" do
    it "should get the right kind of media", :vcr do
      user = Flickrie::User.public_new('nsid' => USER_NSID)
      user.public_photos.each { |object| object.should be_a(Flickrie::Photo) }
      user.public_videos.each { |object| object.should be_a(Flickrie::Video) }
      user.public_media.each  { |object| object.should be_a(Flickrie::Media) }
      user.photos.each { |object| object.should be_a(Flickrie::Photo) }
      user.videos.each { |object| object.should be_a(Flickrie::Video) }
      user.media.each  { |object| object.should be_a(Flickrie::Media) }
    end
  end

  context "blank user" do
    it "should have all attributes equal to nil" do
      attributes = Flickrie::User.instance_methods -
        Object.instance_methods -
        [:public_photos, :public_videos, :public_media,
         :photos, :videos, :media, :[], :get_info]
      user = Flickrie::User.public_new

      attributes.each do |attribute|
        user.send(attribute).should be_nil
      end
    end
  end
end

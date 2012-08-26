require 'spec_helper'

describe :User do
  before(:all) do
    @attributes = {
      id: USER_NSID,
      nsid: USER_NSID,
      username: USER_USERNAME,
      real_name: USER_USERNAME,
      location: "Zagreb, Croatia",
      time_zone: {
        label: "Sarajevo, Skopje, Warsaw, Zagreb",
        offset: "+01:00"
      },
      description: "I'm a programmer, and I'm gonna program a badass Ruby library for Flickr.",
      icon_server: "5464",
      icon_farm: 6,
      :pro? => false,
      media_count: 98
    }
  end

  context "get info", :vcr do
    let(:users) {
      [
        Flickrie.get_user_info(USER_NSID),
        Flickrie::User.public_new('nsid' => USER_NSID).get_info
      ]
    }

    it "has correct attributes" do
      users.each do |user|
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

  context "find by username or email", :vcr do
    let(:users) {
      [
        Flickrie.find_user_by_username(USER_USERNAME),
        Flickrie.find_user_by_email(USER_EMAIL)
      ]
    }

    it "has correct attributes" do
      users.each do |user|
        user.id.should == USER_NSID
        user.nsid.should == USER_NSID
        user.username.should == USER_USERNAME
      end
    end
  end

  context "getting media", :vcr do
    let(:user) { Flickrie::User.public_new('nsid' => USER_NSID) }

    it "gets the right kind of media" do
      user.public_photos.each { |object| object.should be_a(Flickrie::Photo) }
      user.public_videos.each { |object| object.should be_a(Flickrie::Video) }
      user.public_media.each  { |object| object.should be_a(Flickrie::Media) }
      user.photos.each { |object| object.should be_a(Flickrie::Photo) }
      user.videos.each { |object| object.should be_a(Flickrie::Video) }
      user.media.each  { |object| object.should be_a(Flickrie::Media) }
    end
  end

  context "get upload status", :vcr do
    let(:user) { Flickrie.get_upload_status }

    it "has correct attributes" do
      attributes = {
        bandwidth: {
          maximum: 300.0,
          used: 24.294921875,
          remaining: 275.705078125,
          :unlimited? => false
        },
        maximum_photo_size: 30,
        maximum_video_size: 150,

        videos_uploaded: 0,
        videos_remaining: 2,

        sets_created: nil,
        sets_remaining: "lots"
      }

      user.upload_status.should correspond_to(attributes)
    end
  end

  context "blank user" do
    let(:user) { Flickrie::User.public_new({}) }

    it "has all attributes equal to nil" do
      attributes = Flickrie::User.instance_methods -
        Object.instance_methods -
        [:public_photos, :public_videos, :public_media,
         :photos, :videos, :media, :[], :get_info]

      attributes.each do |attribute|
        user.send(attribute).should be_nil
      end
    end
  end
end

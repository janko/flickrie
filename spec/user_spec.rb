# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Flickrie::User do
  context "get info" do
    use_vcr_cassette "user/get_info"

    it "should have all attributes correctly set" do
      [
        Flickrie.get_user_info(USER_NSID),
        Flickrie::User.public_new('nsid' => USER_NSID).get_info
      ].
        each do |user|
          user.id.should eq(USER_NSID)
          user.nsid.should eq(USER_NSID)
          user.username.should eq('Janko Marohnić')
          user.real_name.should eq('Janko Marohnić')
          user.location.should eq('Zagreb, Croatia')
          user.time_zone['label'].should eq('Sarajevo, Skopje, Warsaw, Zagreb')
          user.time_zone['offset'].should eq('+01:00')
          description = "I'm a programmer, and I'm gonna program a badass Ruby library for Flickr."
          user.description.should eq(description)

          user.profile_url.should_not be_empty
          user.mobile_url.should_not be_empty
          user.photos_url.should_not be_empty

          user.icon_server.should eq('5464')
          user.icon_farm.should eq(6)
          user.buddy_icon_url.should_not be_empty

          user.pro?.should be_false

          user.first_taken.should be_an_instance_of(Time)
          user.first_uploaded.should be_an_instance_of(Time)

          user.media_count.should eq(98)
        end
    end
  end

  context "find by username or email" do
    use_vcr_cassette "user/find_by_username_or_email"

    it "should have all attributes correctly set" do
      [
        Flickrie.find_user_by_username('Janko Marohnić'),
        Flickrie.find_user_by_email('janko.marohnic@gmail.com')
      ].
        each do |user|
          user.id.should eq(USER_NSID)
          user.nsid.should eq(USER_NSID)
          user.username.should eq('Janko Marohnić')
        end
    end
  end
end

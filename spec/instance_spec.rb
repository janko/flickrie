# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Flickrie::Instance do
  it "should be able to call API methods", :vcr, :cassette => "calling api methods" do
    # this is to see if the client and upload_client were reset
    Flickrie.get_photo_info(PHOTO_ID)
    Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']
    Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']
    id = Flickrie.upload(PHOTO_PATH)
    Flickrie.delete_photo(id)
    Flickrie.access_token = Flickrie.access_secret = nil

    instance = Flickrie::Instance.new(ENV['FLICKR_ACCESS_TOKEN'], ENV['FLICKR_ACCESS_SECRET'])
    user = instance.test_login
    user.username.should eq("Janko Marohnić")
    id = instance.upload(PHOTO_PATH)
    instance.delete_photo(id)
  end
end

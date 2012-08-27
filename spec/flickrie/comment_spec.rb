require 'spec_helper'

describe :Comment, :vcr do
  context "get_media_comments" do
    let(:comments) { Flickrie.get_media_comments(MEDIA_ID) }

    it "should have correct attributes" do
      comment = comments.first

      comment.id.should_not be_nil

      comment.author.nsid.should == USER_NSID
      comment.author.username.should == USER_USERNAME
      comment.author.icon_server.should be_a(String)
      comment.author.icon_farm.should be_a(Fixnum)

      comment.created_at.should be_a(Time)
      comment.permalink.should be_a(String)
      comment.content.should be_a(String)
      comment.to_s.should == comment.content

      comment.photo.id.should be_a(String)
      comment.video.id.should be_a(String)
    end
  end
end

require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Flickrie::ApiMethods do
  it "should have certain methods working" do
    VCR.use_cassette "api_methods/upload_and_delete" do
      media_id = @flickrie.upload(PHOTO_PATH)
      @flickrie.public_media_from_user(USER_NSID).map(&:id).should include(media_id)
      @flickrie.delete_media(media_id)
      @flickrie.public_media_from_user(USER_NSID).map(&:id).should_not include(media_id)
    end

    VCR.use_cassette "api_methods/asynchronous_upload" do
      ticket_id = @flickrie.upload(PHOTO_PATH, :async => 1)
      begin
        ticket = @flickrie.check_upload_tickets([ticket_id]).first
      end until ticket.complete?
      photo_id = ticket.photo_id
      Flickrie.get_photo_info(photo_id).id.should eq(photo_id)
      @flickrie.delete_photo(photo_id)
    end

    VCR.use_cassette "api_methods/replace" do
      begin
        id = @flickrie.upload(PHOTO_PATH)
        @flickrie.replace(PHOTO_PATH, id)
      rescue => exception
        exception.code.should eq(1) # Not a pro account
      ensure
        @flickrie.delete_media(id)
      end
    end

    VCR.use_cassette "api_methods/tags" do
      media = @flickrie.get_media_info(PHOTO_ID)
      tags_before_change = media.tags.join(' ')
      @flickrie.add_media_tags(PHOTO_ID, "janko")
      media.get_info
      media.tags.join(' ').should eq([tags_before_change, "janko"].join(' '))
      tag_id = media.tags.find { |tag| tag.content == "janko" }.id
      @flickrie.remove_media_tag(tag_id)
      media.get_info
      media.tags.join(' ').should eq(tags_before_change)
    end
  end
end

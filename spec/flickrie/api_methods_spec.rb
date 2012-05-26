require 'spec_helper'

describe Flickrie::ApiMethods do
  context "upload" do
    it "should upload", :vcr do
      photo_id = Flickrie.upload(PHOTO_PATH)
      expect { Flickrie.delete_photo(photo_id) }.to_not raise_error
    end

    it "should upload asynchronously", :vcr do
      ticket_id = Flickrie.upload(PHOTO_PATH, :async => 1)
      ticket = Flickrie.check_upload_tickets(ticket_id).first
      until ticket.complete?
        ticket = Flickrie.check_upload_tickets(ticket_id).first
      end
      expect { Flickrie.delete_photo(ticket.photo_id) }.to_not raise_error
    end

    it "should replace", :vcr do
      begin
        photo_id = Flickrie.upload(PHOTO_PATH)
        Flickrie.replace(PHOTO_PATH, photo_id)
      rescue => error
        error.message.should == "Not a pro account"
      ensure
        Flickrie.delete_photo(photo_id)
      end
    end
  end

  context "people" do
    it "should get media from user", :vcr do
      Flickrie.media_from_user(USER_NSID).first.id.should_not be_nil
      Flickrie.photos_from_user(USER_NSID).first.id.should_not be_nil
      Flickrie.videos_from_user(USER_NSID).first.id.should_not be_nil
    end

    it "should get public media from user", :vcr do
      Flickrie.public_media_from_user(USER_NSID).first.id.should_not be_nil
      Flickrie.public_photos_from_user(USER_NSID).first.id.should_not be_nil
      Flickrie.public_videos_from_user(USER_NSID).first.id.should_not be_nil
    end
  end

  # Here I test the media/photo/video aliases of the API methods (because I don't test them elsewhere)
  context "photos" do
    it "should add and remove tags", :vcr do
      %w[media photo video].each do |word|
        id = eval "#{word.upcase}_ID"
        media = Flickrie.send("get_#{word}_info", id)
        tags_before_change = media.tags.join(' ')
        Flickrie.send("add_#{word}_tags", id, "janko")
        media.get_info
        media.tags.join(' ').should eq([tags_before_change, "janko"].join(' '))
        tag_id = media.tags.find { |tag| tag.content == "janko" }.id
        Flickrie.send("remove_#{word}_tag", tag_id)
        media.get_info
        media.tags.join(' ').should eq(tags_before_change)
      end
    end

    it "should get from contacts", :vcr do
      params = {:include_self => 1, :single_photo => 1}
      Flickrie.media_from_contacts(params).first.id.should_not be_nil
      Flickrie.photos_from_contacts(params).first.id.should_not be_nil
      # Flickrie.videos_from_contacts(params).first.id.should_not be_nil
    end

    it "should get public from user contacts", :vcr do
      params = {:include_self => 1, :single_photo => 1}
      Flickrie.public_media_from_user_contacts(USER_NSID, params).first.id.should_not be_nil
      Flickrie.public_photos_from_user_contacts(USER_NSID, params).first.id.should_not be_nil
      # Flickrie.public_videos_from_user_contacts(USER_NSID, params).each { |object| object.should be_a_video }
    end

    it "should get context", :vcr do
      Flickrie.get_media_context(MEDIA_ID).count.should_not be_nil
      Flickrie.get_photo_context(PHOTO_ID).count.should_not be_nil
      Flickrie.get_photo_context(VIDEO_ID).count.should_not be_nil
    end

    it "should get counts", :vcr do
      dates = [DateTime.parse("19th May 2009"), DateTime.parse("19th May 2012")]
      Flickrie.get_media_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
      Flickrie.get_photos_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
      Flickrie.get_videos_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
    end

    it "should get exif", :vcr do
      Flickrie.get_photo_exif(PHOTO_ID).exif.should_not be_nil
      Flickrie.get_video_exif(VIDEO_ID).exif.should_not be_nil
    end

    it "should get favorites", :vcr do
      Flickrie.get_photo_favorites(PHOTO_ID).favorites.should_not be_nil
      Flickrie.get_video_favorites(PHOTO_ID).favorites.should_not be_nil
    end

    it "should get info", :vcr do
      Flickrie.get_media_info(MEDIA_ID).id.should_not be_nil
      Flickrie.get_photo_info(PHOTO_ID).id.should_not be_nil
      Flickrie.get_video_info(VIDEO_ID).id.should_not be_nil
    end

    it "should get sizes", :vcr do
      Flickrie.get_photo_sizes(PHOTO_ID).size.should_not be_nil
      Flickrie.get_video_sizes(VIDEO_ID).download_url.should_not be_nil
    end

    it "should search", :vcr do
      Flickrie.search_media(:user_id => USER_NSID).first.id.should_not be_nil
      Flickrie.search_photos(:user_id => USER_NSID).first.id.should_not be_nil
      Flickrie.search_videos(:user_id => USER_NSID).first.id.should_not be_nil
    end

    it "should get not in set", :vcr do
      Flickrie.media_not_in_set.each  { |object| object.should be_a(Flickrie::Media) }
      Flickrie.photos_not_in_set.each { |object| object.should be_a(Flickrie::Photo) }
      Flickrie.videos_not_in_set.each { |object| object.should be_a(Flickrie::Video) }
    end
  end

  context "photosets" do
    it "should get media", :vcr do
      Flickrie.media_from_set(SET_ID).first.id.should_not be_nil
      Flickrie.photos_from_set(SET_ID).first.id.should_not be_nil
      Flickrie.videos_from_set(SET_ID).first.id.should_not be_nil
    end
  end
end

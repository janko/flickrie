require 'spec_helper'

describe :ApiMethods do
  context "upload", :vcr do
    it "uploads" do
      photo_id = Flickrie.upload(PHOTO_PATH)
      expect { Flickrie.delete_photo(photo_id) }.to_not raise_error
    end

    it "uploads asynchronously" do
      ticket_id = Flickrie.upload(PHOTO_PATH, :async => 1)
      ticket = Flickrie.check_upload_tickets(ticket_id).first
      until ticket.complete?
        ticket = Flickrie.check_upload_tickets(ticket_id).first
      end
      expect { Flickrie.delete_photo(ticket.photo_id) }.to_not raise_error
    end

    it "replaces" do
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

  context "people", :vcr do
    it "gets media from user" do
      media = Flickrie.media_from_user(USER_NSID)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.photos_from_user(USER_NSID)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.videos_from_user(USER_NSID)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end

    it "gets public media from user" do
      media = Flickrie.public_media_from_user(USER_NSID)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.public_photos_from_user(USER_NSID)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.public_videos_from_user(USER_NSID)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end
  end

  # Here I test the media/photo/video aliases of the API methods (because I don't test them elsewhere)
  context "photos", :vcr do
    it "adds and remove tags" do
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

    it "gets from contacts" do
      params = {:include_self => 1, :single_photo => 1}

      media = Flickrie.media_from_contacts(params)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.photos_from_contacts(params)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.videos_from_contacts(params)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end

    it "gets public from user contacts" do
      params = {:include_self => 1, :single_photo => 1}

      media = Flickrie.public_media_from_user_contacts(USER_NSID, params)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.public_photos_from_user_contacts(USER_NSID, params)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.public_videos_from_user_contacts(USER_NSID, params)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end

    it "gets context" do
      Flickrie.get_media_context(MEDIA_ID).count.should_not be_nil
      Flickrie.get_photo_context(PHOTO_ID).count.should_not be_nil
      Flickrie.get_photo_context(VIDEO_ID).count.should_not be_nil
    end

    it "gets counts" do
      dates = [DateTime.parse("19th May 2009"), DateTime.parse("19th May 2012")]
      Flickrie.get_media_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
      Flickrie.get_photos_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
      Flickrie.get_videos_counts(:taken_dates => dates.join(',')).first.value.should_not be_nil
    end

    it "gets exif" do
      Flickrie.get_photo_exif(PHOTO_ID).exif.should_not be_nil
      Flickrie.get_video_exif(VIDEO_ID).exif.should_not be_nil
    end

    it "gets favorites" do
      Flickrie.get_photo_favorites(PHOTO_ID).favorites.should_not be_nil
      Flickrie.get_video_favorites(PHOTO_ID).favorites.should_not be_nil
    end

    it "gets info" do
      Flickrie.get_media_info(MEDIA_ID).id.should_not be_nil
      Flickrie.get_photo_info(PHOTO_ID).id.should_not be_nil
      Flickrie.get_video_info(VIDEO_ID).id.should_not be_nil
    end

    it "gets sizes" do
      Flickrie.get_photo_sizes(PHOTO_ID).size.should_not be_nil
      Flickrie.get_video_sizes(VIDEO_ID).download_url.should_not be_nil
    end

    it "searches" do
      media = Flickrie.search_media(:user_id => USER_NSID)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.search_photos(:user_id => USER_NSID)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.search_videos(:user_id => USER_NSID)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end

    it "gets not in set" do
      media = Flickrie.media_not_in_set
      media.each { |object| object.should be_a(Flickrie::Media) }
      # media.first.id.should_not be_nil

      photos = Flickrie.photos_not_in_set
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      # photos.first.id.should_not be_nil

      videos = Flickrie.videos_not_in_set
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end

    it "gets of user" do
      media = Flickrie.media_of_user(USER_NSID)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.photos_of_user(USER_NSID)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.videos_of_user(USER_NSID)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end

    it "gets recent" do
      media = Flickrie.get_recent_media
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.get_recent_photos
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.get_recent_videos
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end

    it "gets untagged" do
      media = Flickrie.get_untagged_media
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.get_untagged_photos
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.get_untagged_videos
      videos.each { |object| object.should be_a(Flickrie::Video) }
      # videos.first.id.should_not be_nil
    end
  end

  context "photosets", :vcr do
    it "gets media" do
      media = Flickrie.media_from_set(SET_ID)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.photos_from_set(SET_ID)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.videos_from_set(SET_ID)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end
  end
end

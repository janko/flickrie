require 'spec_helper'

describe :ApiMethods, :vcr do
  context "upload" do
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

  context "people" do
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
  context "photos" do
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

    it "gets with geo data" do
      media = Flickrie.get_media_with_geo_data
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.get_photos_with_geo_data
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.get_videos_with_geo_data
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end

    it "gets without geo data" do
      media = Flickrie.get_media_without_geo_data
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.get_photos_without_geo_data
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.get_videos_without_geo_data
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end

    it "gets recently updated" do
      media = Flickrie.recently_updated_media(:min_date => DateTime.parse("1st May 2011").to_time.to_i)
      media.each { |object| object.should be_a(Flickrie::Media) }
      media.first.id.should_not be_nil

      photos = Flickrie.recently_updated_photos(:min_date => DateTime.parse("1st May 2011").to_time.to_i)
      photos.each { |object| object.should be_a(Flickrie::Photo) }
      photos.first.id.should_not be_nil

      videos = Flickrie.recently_updated_videos(:min_date => DateTime.parse("1st May 2011").to_time.to_i)
      videos.each { |object| object.should be_a(Flickrie::Video) }
      videos.first.id.should_not be_nil
    end

    it "sets content type" do
      Flickrie.set_media_content_type(MEDIA_ID, 1)
      Flickrie.set_photo_content_type(PHOTO_ID, 1)
      Flickrie.set_video_content_type(VIDEO_ID, 1)
    end

    it "sets dates" do
      Flickrie.set_media_dates(MEDIA_ID, :date_taken_granularity => 0)
      Flickrie.set_photo_dates(MEDIA_ID, :date_taken_granularity => 0)
      Flickrie.set_video_dates(MEDIA_ID, :date_taken_granularity => 0)
    end

    it "sets meta" do
      Flickrie.set_media_meta(MEDIA_ID, :title => "IMG_0796", :description => "Test")
      Flickrie.set_photo_meta(MEDIA_ID, :title => "IMG_0796", :description => "Test")
      Flickrie.set_video_meta(MEDIA_ID, :title => "IMG_0796", :description => "Test")
    end

    it "sets permissions" do
      Flickrie.set_media_permissions(MEDIA_ID, :is_public => 1, :is_friend => 0, :is_family => 0, :perm_comment => 3, :perm_addmeta => 2)
      Flickrie.set_photo_permissions(MEDIA_ID, :is_public => 1, :is_friend => 0, :is_family => 0, :perm_comment => 3, :perm_addmeta => 2)
      Flickrie.set_video_permissions(MEDIA_ID, :is_public => 1, :is_friend => 0, :is_family => 0, :perm_comment => 3, :perm_addmeta => 2)
    end

    it "sets safety level" do
      Flickrie.set_media_safety_level(MEDIA_ID, :safety_level => 1)
      Flickrie.set_photo_safety_level(MEDIA_ID, :safety_level => 1)
      Flickrie.set_video_safety_level(MEDIA_ID, :safety_level => 1)
    end

    it "sets tags" do
      Flickrie.set_media_tags(MEDIA_ID, 'luka')
      Flickrie.set_photo_tags(MEDIA_ID, 'luka')
      Flickrie.set_video_tags(MEDIA_ID, 'luka')
    end

    it "sets license" do
      Flickrie.set_media_license(MEDIA_ID, 0)
      Flickrie.set_photo_license(MEDIA_ID, 0)
      Flickrie.set_video_license(MEDIA_ID, 0)
    end

    it "rotates" do
      Flickrie.rotate_media(MEDIA_ID, 90)
      Flickrie.rotate_photo(MEDIA_ID, 90)
      Flickrie.rotate_video(MEDIA_ID, 180)
    end
  end

  context "photosets" do
    it "adds media" do
      expect { Flickrie.add_media_to_set(72157630665363720, PHOTO_ID) }.to_not raise_error
    end

    it "deletes" do
      expect { Flickrie.delete_set(72157630665647968) }.to_not raise_error
    end

    it "edits meta" do
      expect { Flickrie.edit_set_metadata(SET_ID, :title => "Speleologija") }.to_not raise_error
    end

    it "edits media" do
      expect { Flickrie.edit_set_media(72157630665363720, :primary_photo_id => 7093101501, :photo_ids => "7093101501,7316710626") }.to_not raise_error
    end

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

    it "orders" do
      expect { Flickrie.order_sets(SET_ID) }.to_not raise_error
    end

    it "removes media" do
      expect { Flickrie.remove_media_from_set(72157630666246536, 7316710626) }.to_not raise_error
      expect { Flickrie.remove_media_from_set(72157630666246536, "7316710626,7093101501") }.to_not raise_error
    end
  end
end

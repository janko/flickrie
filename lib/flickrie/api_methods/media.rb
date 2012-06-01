module Flickrie
  module ApiMethods
    # Fetches photos and videos from the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def media_from_user(nsid, params = {})
      response = client.media_from_user(nsid, params)
      Media.from_user(response.body['photos'])
    end
    # Fetches photos from the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def photos_from_user(nsid, params = {})
      media_from_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    # Fetches videos from the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def videos_from_user(nsid, params = {})
      media_from_user(nsid, params).select { |media| media.is_a?(Video) }
    end

    # Fetches photos and videos containing a Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def media_of_user(nsid, params = {})
      response = client.media_of_user(nsid, params)
      Media.of_user(response.body['photos'])
    end
    # Fetches photos containing a Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def photos_of_user(nsid, params = {})
      media_of_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    # Fetches videos containing a Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def videos_of_user(nsid, params = {})
      media_of_user(nsid, params).select { |media| media.is_a?(Video) }
    end

    # Fetches public photos and videos from the Flickr user with the given
    # NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def public_media_from_user(nsid, params = {})
      response = client.public_media_from_user(nsid, params)
      Media.from_user(response.body['photos'])
    end
    # Fetches public photos from the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def public_photos_from_user(nsid, params = {})
      public_media_from_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    # Fetches public videos from the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def public_videos_from_user(nsid, params = {})
      public_media_from_user(nsid, params).select { |media| media.is_a?(Video) }
    end

    # Add tags to the photo/video with the given ID.
    #
    # @param media_id [String, Fixnum]
    # @param tags [String] A space delimited string with tags
    # @return [nil]
    # @api_method [flickr.photos.addTags](http://www.flickr.com/services/api/flickr.photos.addTags.html)
    #
    # @note This method requires authentication with "write" permissions.
    def add_media_tags(media_id, tags, params = {})
      client.add_media_tags(media_id, tags, params)
      nil
    end
    alias add_photo_tags add_media_tags
    alias add_video_tags add_media_tags

    # Deletes the photo/video with the given ID.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.delete](http://www.flickr.com/services/api/flickr.photos.delete.html)
    #
    # @note This method requires authentication with "delete" permissions.
    def delete_media(media_id, params = {})
      client.delete_media(media_id, params)
      nil
    end
    alias delete_photo delete_media
    alias delete_video delete_media

    # Fetches photos and videos from contacts of the user who authenticated.
    #
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def media_from_contacts(params = {})
      response = client.media_from_contacts(params)
      Media.from_contacts(response.body['photos'])
    end
    # Fetches photos from contacts of the user who authenticated.
    #
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def photos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Photo) }
    end
    # Fetches videos from contacts of the user who authenticated.
    #
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def videos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Video) }
    end

    # Fetches public photos and videos from contacts of the user with the
    # given NSID.
    #
    # @param nsid [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def public_media_from_user_contacts(nsid, params = {})
      response = client.public_media_from_user_contacts(nsid, params)
      Media.from_contacts(response.body['photos'])
    end
    # Fetches public photos from contacts of the user with the
    # given NSID.
    #
    # @param nsid [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def public_photos_from_user_contacts(nsid, params = {})
      public_media_from_user_contacts(nsid, params).
        select { |media| media.is_a?(Photo) }
    end
    # Fetches public videos from contacts of the user with the
    # given NSID.
    #
    # @param nsid [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def public_videos_from_user_contacts(nsid, params = {})
      public_media_from_user_contacts(nsid, params).
        select { |media| media.is_a?(Video) }
    end

    # Fetches context of the photo/video with the given ID. Example:
    #
    #     context = Flickrie.get_photo_context(37124234)
    #     context.count    # => 23
    #     context.previous # => #<Photo: id=2433240, ...>
    #     context.next     # => #<Video: id=1282404, ...>
    #
    # @param media_id [String, Fixnum]
    # @return [Struct]
    # @api_method [flickr.photos.getContext](http://www.flickr.com/services/api/flickr.photos.getContext.html)
    def get_media_context(media_id, params = {})
      response = client.get_media_context(media_id, params)
      Media.from_context(response.body)
    end
    alias get_photo_context get_media_context
    alias get_video_context get_media_context

    # Fetches numbers of photos and videos for given date ranges. Example:
    #
    #     require 'date'
    #     dates = [DateTime.parse("3rd Jan 2011").to_time, DateTime.parse("11th Aug 2011").to_time]
    #     counts = Flickrie.get_media_counts(:taken_dates => dates.map(&:to_i).join(','))
    #
    #     count = counts.first
    #     count.value            # => 24
    #     count.date_range       # => 2011-01-03 01:00:00 +0100..2011-08-11 02:00:00 +0200
    #     count.date_range.begin # => 2011-01-03 01:00:00 +0100
    #     count.from             # => 2011-01-03 01:00:00 +0100
    #
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::MediaCount]
    # @api_method [flickr.photos.getCounts](http://www.flickr.com/services/api/flickr.photos.getCounts.html)
    def get_media_counts(params = {})
      response = client.get_media_counts \
        MediaCount.ensure_utc(params)
      response.body['photocounts']['photocount'].
        map { |info| MediaCount.new(info, params) }
    end
    alias get_photos_counts get_media_counts
    alias get_videos_counts get_media_counts

    # Fetches the exif for the photo with the given ID. Example:
    #
    #     photo = Flickrie.get_photo_exif(27234987)
    #     photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #     photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #     photo.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getExif](http://www.flickr.com/services/api/flickr.photos.getExif.html)
    def get_photo_exif(photo_id, params = {})
      response = client.get_media_exif(photo_id, params)
      Photo.new(response.body['photo'])
    end
    # Fetches the exif for the video with the given ID. Example:
    #
    #     video = Flickrie.get_video_exif(27234987)
    #     video.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     video.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #     video.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #     video.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getExif](http://www.flickr.com/services/api/flickr.photos.getExif.html)
    def get_video_exif(video_id, params = {})
      response = client.get_media_exif(video_id, params)
      Video.new(response.body['photo'])
    end

    # Fetches the list of users who favorited the photo with the given ID.
    # Example:
    #
    #     photo = Flickrie.get_photo_favorites(24810948)
    #     photo.favorites.first.username # => "John Smith"
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getFavorites](http://www.flickr.com/services/api/flickr.photos.getFavorites.html)
    def get_photo_favorites(photo_id, params = {})
      response = client.get_media_favorites(photo_id, params)
      Photo.new(response.body['photo'])
    end
    # Fetches the list of users who favorited the video with the given ID.
    # Example:
    #
    #     video = Flickrie.get_video_favorites(24810948)
    #     video.favorites.first.username # => "John Smith"
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getFavorites](http://www.flickr.com/services/api/flickr.photos.getFavorites.html)
    def get_video_favorites(video_id, params = {})
      response = client.get_media_favorites(video_id, params)
      Video.new(response.body['photo'])
    end

    # Fetches info of the photo/video with the given ID.
    #
    # @param media_id [String, Fixnum]
    # @return [Flickrie::Photo, Flickrie::Video]
    # @api_method [flickr.photos.getInfo](http://www.flickr.com/services/api/flickr.photos.getInfo.html)
    def get_media_info(media_id, params = {})
      response = client.get_media_info(media_id, params)
      Media.from_info(response.body['photo'])
    end
    alias get_photo_info get_media_info
    alias get_video_info get_media_info

    # Fetches photos and videos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def media_not_in_set(params = {})
      response = client.media_not_in_set({:media => 'all'}.merge(params))
      Media.from_not_in_set(response.body['photos'])
    end
    # Fetches photos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def photos_not_in_set(params = {})
      media_not_in_set({:media => "photos"}.merge(params))
    end
    # Fetches videos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def videos_not_in_set(params = {})
      media_not_in_set({:media => "videos"}.merge(params))
    end

    # Gets permissions of a photo with the given ID.
    #
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getPerms](http://www.flickr.com/services/api/flickr.photos.getPerms.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photo_permissions(photo_id, params = {})
      response = client.get_media_permissions(photo_id, params)
      Photo.from_perms(response.body['perms'])
    end
    # Gets permissions of a video with the given ID.
    #
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getPerms](http://www.flickr.com/services/api/flickr.photos.getPerms.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_video_permissions(video_id, params = {})
      response = client.get_media_permissions(video_id, params)
      Video.from_perms(response.body['perms'])
    end

    # Fetches the latest photos and videos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_media(params = {})
      response = client.get_recent_media(params)
      Media.from_recent(response.body['photos'])
    end
    # Fetches the latest photos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_photos(params = {})
      get_recent_media(params).select { |media| media.is_a?(Photo) }
    end
    # Fetches the latest videos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_videos(params = {})
      get_recent_media(params).select { |media| media.is_a?(Video) }
    end

    # Fetches the sizes of the photo with the given ID. Example:
    #
    #     photo = Flickrie.get_photo_sizes(242348)
    #     photo.medium!(500)
    #     photo.size       # => "Medium 500"
    #     photo.source_url # => "http://farm8.staticflickr.com/7090/7093101501_9337f28800.jpg"
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getSizes](http://www.flickr.com/services/api/flickr.photos.getSizes.html)
    def get_photo_sizes(photo_id, params = {})
      response = client.get_media_sizes(photo_id, params)
      Photo.from_sizes(response.body['sizes'].merge('id' => photo_id.to_s))
    end
    # Fetches the sizes of the video with the given ID. Example:
    #
    #     video = Flickrie.get_video_sizes(438492)
    #     video.download_url # => "..."
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getSizes](http://www.flickr.com/services/api/flickr.photos.getSizes.html)
    def get_video_sizes(video_id, params = {})
      response = client.get_media_sizes(video_id, params)
      Video.from_sizes(response.body['sizes'].merge('id' => video_id.to_s))
    end

    # Fetches photos and videos from the authenticated user that have no
    # tags.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_media(params = {})
      response = client.get_untagged_media({:media => 'all'}.merge(params))
      Media.from_untagged(response.body['photos'])
    end
    # Fetches photos from the authenticated user that have no tags.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_photos(params = {})
      get_untagged_media({:media => 'photos'}.merge(params))
    end
    # Fetches videos from the authenticated user that have no tags.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_videos(params = {})
      get_untagged_media({:media => 'videos'}.merge(params))
    end

    # Fetches geo-tagged photos and videos from the authenticated user.
    #
    # @return [Flickrie:Collection<Flickrie:Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_with_geo_data(params = {})
      response = client.get_media_with_geo_data({:media => 'all'}.merge(params))
      Media.from_geo_data(response.body['photos'])
    end
    # Fetches geo-tagged photos from the authenticated user.
    #
    # @return [Flickrie:Collection<Flickrie:Photo>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_with_geo_data(params = {})
      get_media_with_geo_data({:media => 'photos'}.merge(params))
    end
    # Fetches geo-tagged videos from the authenticated user.
    #
    # @return [Flickrie:Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_with_geo_data(params = {})
      get_media_with_geo_data({:media => 'videos'}.merge(params))
    end

    # Fetches photos and videos from the authenticated user that are not
    # geo-tagged.
    #
    # @return [Flickrie:Collection<Flickrie:Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_without_geo_data(params = {})
      response = client.get_media_with_geo_data({:media => 'all'}.merge(params))
      Media.from_geo_data(response.body['photos'])
    end
    # Fetches photos from the authenticated user that are not geo-tagged.
    #
    # @return [Flickrie:Collection<Flickrie:Photo>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_without_geo_data(params = {})
      get_media_with_geo_data({:media => 'photos'}.merge(params))
    end
    # Fetches videos from the authenticated user that are not geo-tagged.
    #
    # @return [Flickrie:Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_without_geo_data(params = {})
      get_media_with_geo_data({:media => 'videos'}.merge(params))
    end

    # Fetches photos and videos from the authenticated user that have
    # recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def recently_updated_media(params = {})
      response = client.recently_updated_media(params)
      Media.from_recently_updated(response.body['photos'])
    end
    # Fetches photos from the authenticated user that have recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def recently_updated_photos(params = {})
      recently_updated_media(params).select { |media| media.is_a?(Photo) }
    end
    # Fetches videos from the authenticated user that have recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def recently_updated_videos(params = {})
      recently_updated_media(params).select { |media| media.is_a?(Video) }
    end

    # Remove the tag with the given ID
    #
    # @param tag_id [String]
    # @return [nil]
    # @api_method [flickr.photos.removeTag](http://www.flickr.com/services/api/flickr.photos.removeTag.html)
    #
    # @note This method requires authentication with "write" permissions.
    def remove_media_tag(tag_id, params = {})
      client.remove_media_tag(tag_id, params)
      nil
    end
    alias remove_photo_tag remove_media_tag
    alias remove_video_tag remove_media_tag

    # Fetches photos and videos matching a certain criteria.
    #
    # @param search_params [Hash] Options for searching (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_media(params = {})
      response = client.search_media({:media => 'all'}.merge(params))
      Media.from_search(response.body['photos'])
    end
    # Fetches photos matching a certain criteria.
    #
    # @param search_params [Hash] Options for searching (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_photos(params = {})
      search_media({:media => 'photos'}.merge(params))
    end
    # Fetches videos matching a certain criteria.
    #
    # @param search_params [Hash] Options for searching (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_videos(params = {})
      search_media({:media => 'videos'}.merge(params))
    end

    # Sets the content type of a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @param content_type [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setContentType](http://www.flickr.com/services/api/flickr.photos.setContentType.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_content_type(media_id, content_type, params = {})
      client.set_media_content_type(media_id, content_type, params)
      nil
    end
    alias set_photo_content_type set_media_content_type
    alias set_video_content_type set_media_content_type

    # Sets dates for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setDates](http://www.flickr.com/services/api/flickr.photos.setDates.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_dates(media_id, params = {})
      client.set_media_dates(media_id, params)
      nil
    end
    alias set_photo_dates set_media_dates
    alias set_video_dates set_media_dates

    # Sets meta information for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setMeta](http://www.flickr.com/services/api/flickr.photos.setMeta.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_meta(media_id, params = {})
      client.set_media_meta(media_id, params)
      nil
    end
    alias set_photo_meta set_media_meta
    alias set_video_meta set_media_meta

    # Sets permissions for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setPerms](http://www.flickr.com/services/api/flickr.photos.setPerms.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_permissions(media_id, params = {})
      client.set_media_permissions(media_id, params)
      nil
    end
    alias set_photo_permissions set_media_permissions
    alias set_video_permissions set_media_permissions

    # Sets the safety level of a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setSafetyLevel](http://www.flickr.com/services/api/flickr.photos.setSafetyLevel.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_safety_level(media_id, params = {})
      client.set_media_safety_level(media_id, params)
      nil
    end
    alias set_photo_safety_level set_media_safety_level
    alias set_video_safety_level set_media_safety_level

    # Sets tags for a photo/video.
    #
    # @params media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setTags](http://www.flickr.com/services/api/flickr.photos.setTags.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_tags(media_id, tags, params = {})
      client.set_media_tags(media_id, tags, params)
      nil
    end
    alias set_photo_tags set_media_tags
    alias set_video_tags set_media_tags

    # Sets the license of a photo/video.
    #
    # @return [nil]
    # @api_method [flickr.photos.licenses.setLicense](http://www.flickr.com/services/api/flickr.photos.licenses.setLicense.html)
<<<<<<< HEAD
    #
    # @note This method requires authentication with "write" permissions.
=======
>>>>>>> 4cdc287... Split API methods into multiple files
    def set_media_license(media_id, license_id, params = {})
      client.set_media_license(media_id, license_id, params)
      nil
    end
    alias set_photo_license set_media_license
    alias set_video_license set_media_license

<<<<<<< HEAD
    # Rotates a photo/video.
    #
    # @return [nil]
    # @api_method [flickr.photos.transform.rotate](http://www.flickr.com/services/api/flickr.photos.transform.rotate.html)
    #
    # @note This method requires authentication with "write" permissions.
    def rotate_media(media_id, degrees, params = {})
      client.rotate_media(media_id, degrees, params)
      nil
    end
    alias rotate_photo rotate_media
    alias rotate_video rotate_media

=======
>>>>>>> 4cdc287... Split API methods into multiple files
    # Fetches photos and videos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def media_from_set(set_id, params = {})
      response = client.media_from_set(set_id, {:media => 'all'}.merge(params))
      Media.from_set(response.body['photoset'])
    end
    # Fetches photos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def photos_from_set(set_id, params = {})
      media_from_set(set_id, {:media => 'photos'}.merge(params))
    end
    # Fetches videos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def videos_from_set(set_id, params = {})
      media_from_set(set_id, {:media => 'videos'}.merge(params))
    end
  end
end

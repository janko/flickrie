module Flickrie
  module ApiMethods
    # For uploading photos and videos to Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = Flickrie.upload(path, :title => "Me and Jessica", :description => "...")
    #     photo = Flickrie.get_photo_info(photo_id)
    #     photo.title # => "Me and Jessica"
    #
    # If the `:async => 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param params [Hash] Options for uploading (see [this page](http://www.flickr.com/services/api/upload.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `:async => 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def upload(media, params = {})
      response = upload_client.upload(media, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # For replacing photos and videos on Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = 42374 # ID of the photo to be replaced
    #     id = Flickrie.replace(path, photo_id)
    #
    # If the `:async => 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param media_id [String, Fixnum] The ID of the photo/video to be replaced
    # @param params [Hash] Options for replacing (see [this page](http://www.flickr.com/services/api/replace.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `:async => 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def replace(media, media_id, params = {})
      response = upload_client.replace(media, media_id, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # Fetches the Flickr user with the given email.
    #
    # @param email [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByEmail](http://www.flickr.com/services/api/flickr.people.findByEmail.html)
    def find_user_by_email(email, params = {})
      response = client.find_user_by_email(email, params)
      User.from_find(response.body['user'])
    end

    # Fetches the Flickr user with the given username.
    #
    # @param username [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByUsername](http://www.flickr.com/services/api/flickr.people.findByUsername.html)
    def find_user_by_username(username, params = {})
      response = client.find_user_by_username(username, params)
      User.from_find(response.body['user'])
    end

    # Fetches the Flickr user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::User]
    # @api_method [flickr.people.getInfo](http://www.flickr.com/services/api/flickr.people.getInfo.html)
    def get_user_info(nsid, params = {})
      response = client.get_user_info(nsid, params)
      User.from_info(response.body['person'])
    end

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

    # Returns the upload status of the user who is currently authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.getUploadStatus](http://www.flickr.com/services/api/flickr.people.getUploadStatus.html)
    # @see Flickrie::User#upload_status
    #
    # @note This method requires authentication with "read" permissions.
    def get_upload_status(params = {})
      response = client.get_upload_status(params)
      User.from_upload_status(response.body['user'])
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
      response = client.media_not_in_set(params)
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
      media_not_in_set(params.merge(:media => "photos"))
    end
    # Fetches videos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def videos_not_in_set(params = {})
      media_not_in_set(params.merge(:media => "videos"))
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
    def search_media(search_params = {})
      response = client.search_media(search_params)
      Media.from_search(response.body['photos'])
    end
    # Fetches photos matching a certain criteria.
    #
    # @param search_params [Hash] Options for searching (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_photos(search_params = {})
      search_media(search_params.merge(:media => 'photos'))
    end
    # Fetches videos matching a certain criteria.
    #
    # @param search_params [Hash] Options for searching (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_videos(search_params = {})
      search_media(search_params.merge(:media => 'videos'))
    end

    # Fetches all available types of licenses.
    #
    # @return [Array<Flickrie::License>]
    # @api_method [flickr.photos.licenses.getInfo](http://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html)
    def get_licenses(params = {})
      response = client.get_licenses(params)
      License.from_hash(response.body['licenses']['license'])
    end

    # Fetches upload tickets with given IDs. Example:
    #
    #     photo = File.open("...")
    #     ticket_id = Flickrie.upload(photo, :async => 1)
    #     sleep(10)
    #
    #     ticket = Flickrie.check_upload_tickets(ticket_id)
    #     if ticket.complete?
    #       puts "Photo was uploaded, and its ID is #{ticket.photo_id}"
    #     end
    #
    # @param tickets [String] A space delimited string with ticket IDs
    # @return [Flickrie::Ticket]
    # @api_method [flickr.photos.upload.checkTickets](http://www.flickr.com/services/api/flickr.photos.upload.checkTickets.html)
    def check_upload_tickets(tickets, params = {})
      ticket_ids = tickets.join(',') rescue tickets
      response = client.check_upload_tickets(ticket_ids, params)
      response.body['uploader']['ticket'].
        map { |info| Ticket.new(info) }
    end

    # Fetches information about the set with the given ID.
    #
    # @param set_id [String, Fixnum]
    # @return [Flickrie::Set]
    # @api_method [flickr.photosets.getInfo](http://www.flickr.com/services/api/flickr.photosets.getInfo.html)
    def get_set_info(set_id, params = {})
      response = client.get_set_info(set_id, params)
      Set.from_info(response.body['photoset'])
    end

    # Fetches sets from a user with the given NSID.
    #
    # @param nsid [String]
    # @return [Flickrie::Collection<Flickrie::Set>]
    # @api_method [flickr.photosets.getList](http://www.flickr.com/services/api/flickr.photosets.getList.html)
    def sets_from_user(nsid, params = {})
      response = client.sets_from_user(nsid, params)
      Set.from_user(response.body['photosets'], nsid)
    end

    # Fetches photos and videos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def media_from_set(set_id, params = {})
      response = client.media_from_set(set_id, params)
      Media.from_set(response.body['photoset'])
    end
    # Fetches photos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def photos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'photos'))
    end
    # Fetches videos from a set with the given ID.
    #
    # @param set_id [String]
    # @param params [Hash] Options for this API method (see the link below under "Flickr API method")
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def videos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'videos'))
    end

    # Tests if the authentication was successful. If it was, it
    # returns info of the user who just authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.test.login](http://www.flickr.com/services/api/flickr.test.login.html)
    #
    # @note This method requires authentication with "read" permissions.
    def test_login(params = {})
      response = client.test_login(params)
      User.from_test(response.body['user'])
    end
  end
end

module Flickrie
  class Client
    def methods
      @methods ||= {
        "flickr.people.findByEmail"                   => [:get, ->(email, params = {}) { {find_email: email}.merge(params) }],
        "flickr.people.findByUsername"                => [:get, ->(username, params = {}) { {username: username}.merge(params) }],
        "flickr.people.getInfo"                       => [:get, ->(nsid, params = {}) { {user_id: nsid}.merge(params) }],
        "flickr.people.getPhotos"                     => [:get, ->(nsid, params = {}) { ensure_media({user_id: nsid}.merge(params)) }],
        "flickr.people.getPhotosOf"                   => [:get, ->(nsid, params = {}) { ensure_media({user_id: nsid}.merge(params)) }],
        "flickr.people.getPublicPhotos"               => [:get, ->(nsid, params = {}) { ensure_media({user_id: nsid}.merge(params)) }],
        "flickr.people.getUploadStatus"               => [:get, ->(params = {}) { params }],

        "flickr.photos.addTags"                       => [:post, ->(media_id, tags, params = {}) { {photo_id: media_id, tags: tags}.merge(params) }],
        "flickr.photos.delete"                        => [:post, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getContactsPhotos"             => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.getContactsPublicPhotos"       => [:get, ->(nsid, params = {}) { ensure_media({user_id: nsid}.merge(params)) }],
        "flickr.photos.getContext"                    => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getCounts"                     => [:get, ->(params = {}) { ensure_utc(params) }],
        "flickr.photos.getExif"                       => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getFavorites"                  => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getInfo"                       => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getNotInSet"                   => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.getPerms"                      => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getRecent"                     => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.getSizes"                      => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.getUntagged"                   => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.getWithGeoData"                => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.getWithoutGeoData"             => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.recentlyUpdated"               => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.removeTag"                     => [:post, ->(tag_id, params = {}) { {tag_id: tag_id}.merge(params) }],
        "flickr.photos.search"                        => [:get, ->(params = {}) { ensure_media(params) }],
        "flickr.photos.setContentType"                => [:post, ->(media_id, content_type, params = {}) { {photo_id: media_id, content_type: content_type}.merge(params) }],
        "flickr.photos.setDates"                      => [:post, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.setMeta"                       => [:post, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.setPerms"                      => [:post, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.setSafetyLevel"                => [:post, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.setTags"                       => [:post, ->(media_id, tags, params = {}) { {photo_id: media_id, tags: tags}.merge(params) }],

        "flickr.photos.comments.addComment"           => [:post, ->(media_id, comment, params = {}) { {photo_id: media_id, comment_text: comment}.merge(params) }],
        "flickr.photos.comments.deleteComment"        => [:post, ->(comment_id, params = {}) { {comment_id: comment_id}.merge(params) }],
        "flickr.photos.comments.editComment"          => [:post, ->(comment_id, comment, params = {}) { {comment_id: comment_id, comment_text: comment}.merge(params) }],
        "flickr.photos.comments.getList"              => [:get, ->(media_id, params = {}) { {photo_id: media_id}.merge(params) }],
        "flickr.photos.comments.getRecentForContacts" => [:get, ->(params = {}) { ensure_media(params) }],

        "flickr.photos.upload.checkTickets"           => [:get, ->(tickets, params = {}) { {tickets: tickets}.merge(params) }],

        "flickr.photos.licenses.getInfo"              => [:get, ->(params = {}) { params }],
        "flickr.photos.licenses.setLicense"           => [:post, ->(media_id, license_id, params = {}) { {photo_id: media_id, license_id: license_id}.merge(params) }],

        "flickr.photos.transform.rotate"              => [:post, ->(media_id, degrees, params = {}) { {photo_id: media_id, degrees: degrees}.merge(params) }],

        "flickr.photosets.addPhoto"                   => [:post, ->(set_id, media_id, params = {}) { {photoset_id: set_id, photo_id: media_id}.merge(params) }],
        "flickr.photosets.create"                     => [:post, ->(params = {}) { params }],
        "flickr.photosets.delete"                     => [:post, ->(set_id, params = {}) { {photoset_id: set_id}.merge(params) }],
        "flickr.photosets.editMeta"                   => [:post, ->(set_id, params = {}) { {photoset_id: set_id}.merge(params) }],
        "flickr.photosets.editPhotos"                 => [:post, ->(set_id, params = {}) { {photoset_id: set_id}.merge(params) }],
        "flickr.photosets.getContext"                 => [:get, ->(set_id, media_id, params = {}) { {photoset_id: set_id, photo_id: media_id}.merge(params) }],
        "flickr.photosets.getInfo"                    => [:get, ->(set_id, params = {}) { {photoset_id: set_id}.merge(params) }],
        "flickr.photosets.getList"                    => [:get, ->(nsid, params = {}) { {user_id: nsid}.merge(params) }],
        "flickr.photosets.getPhotos"                  => [:get, ->(set_id, params = {}) { ensure_media({photoset_id: set_id}.merge(params)) }],
        "flickr.photosets.orderSets"                  => [:post, ->(set_ids, params = {}) { {photoset_ids: set_ids}.merge(params) }],
        "flickr.photosets.removePhotos"               => [:post, ->(set_id, media_ids, params = {}) { {photoset_id: set_id, photo_ids: media_ids}.merge(params) }],
        "flickr.photosets.reorderPhotos"              => [:post, ->(set_id, media_ids, params = {}) { {photoset_id: set_id, photo_ids: media_ids}.merge(params) }],
        "flickr.photosets.setPrimaryPhoto"            => [:post, ->(set_id, media_id, params = {}) { {photoset_id: set_id, photo_id: media_id}.merge(params) }],
        "flickr.reflection.getMethods"                => [:get, ->(params = {}) { params }],

        "flickr.test.login"                           => [:get, ->(params = {}) { params }],
      }
    end

    private

    def ensure_media(params)
      params.dup.tap do |dup_params|
        dup_params[:extras] = [dup_params[:extras], 'media'].compact.join(',')
      end
    end

    def ensure_utc(params)
      params.dup.tap do |hash|
        if hash[:taken_dates].is_a?(String)
          hash[:taken_dates] = hash[:taken_dates].split(',').
            map { |date| DateTime.parse(date) }.
            map(&:to_time).map(&:getutc).join(',')
        end
      end
    end
  end
end

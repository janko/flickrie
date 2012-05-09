require 'flickrie/client'
require 'flickrie/upload_client'
require 'flickrie/oauth'
require 'flickrie/license'
require 'flickrie/user'
require 'flickrie/media'
require 'flickrie/photo'
require 'flickrie/video'
require 'flickrie/set'
require 'flickrie/media_count'
require 'flickrie/ticket'

module Flickrie
  module ApiMethods
    def upload(media, params = {})
      response = upload_client.upload(media, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    def replace(media, media_id, params = {})
      response = upload_client.replace(media, media_id, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    #--
    # people
    def find_user_by_email(email, params = {})
      response = client.find_user_by_email(email, params)
      User.from_find(response.body['user'])
    end

    def find_user_by_username(username, params = {})
      response = client.find_user_by_username(username, params)
      User.from_find(response.body['user'])
    end

    def get_user_info(user_nsid, params = {})
      response = client.get_user_info(user_nsid, params)
      User.from_info(response.body['person'])
    end

    def public_media_from_user(user_nsid, params = {})
      response = client.public_media_from_user(user_nsid, params)
      Media.from_user(response.body['photos'])
    end
    def public_photos_from_user(user_nsid, params = {})
      public_media_from_user(user_nsid, params).
        select { |media| media.is_a?(Photo) }
    end
    def public_videos_from_user(user_nsid, params = {})
      public_media_from_user(user_nsid, params).
        select { |media| media.is_a?(Video) }
    end

    #--
    # photos
    def add_media_tags(media_id, tags, params = {})
      client.add_media_tags(media_id, tags, params)
    end
    alias add_photo_tags add_media_tags
    alias add_video_tags add_media_tags

    def delete_media(media_id, params = {})
      client.delete_media(media_id, params)
      media_id
    end
    alias delete_photo delete_media
    alias delete_video delete_media

    def media_from_contacts(params = {})
      response = client.media_from_contacts(params)
      Media.from_contacts(response.body['photos'])
    end
    def photos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Photo) }
    end
    def videos_from_contacts(params = {})
      media_from_contacts(params).select { |media| media.is_a?(Video) }
    end

    def public_media_from_user_contacts(user_nsid, params = {})
      response = client.public_media_from_user_contacts(user_nsid, params)
      Media.from_contacts(response.body['photos'])
    end
    def public_photos_from_user_contacts(user_nsid, params = {})
      public_media_from_user_contacts(user_nsid, params).
        select { |media| media.is_a?(Photo) }
    end
    def public_videos_from_user_contacts(user_nsid, params = {})
      public_media_from_user_contacts(user_nsid, params).
        select { |media| media.is_a?(Photo) }
    end

    def get_media_context(media_id, params = {})
      response = client.get_media_context(media_id, params)
      Media.from_context(response.body)
    end
    alias get_photo_context get_media_context
    alias get_video_context get_media_context

    def get_media_counts(params = {})
      response = client.get_media_counts \
        MediaCount.ensure_utc(params)
      response.body['photocounts']['photocount'].
        map { |info| MediaCount.new(info, params) }
    end
    alias get_photos_counts get_media_counts
    alias get_videos_counts get_media_counts

    def get_photo_exif(photo_id, params = {})
      response = client.get_media_exif(photo_id, params)
      Photo.from_exif(response.body['photo'])
    end
    def get_video_exif(video_id, params = {})
      response = client.get_media_exif(video_id, params)
      Video.from_exif(response.body['photo'])
    end

    def get_photo_favorites(photo_id, params = {})
      response = client.get_media_favorites(photo_id, params)
      Photo.new(response.body['photo'])
    end
    def get_video_favorites(video_id, params = {})
      response = client.get_media_favorites(video_id, params)
      Video.new(response.body['photo'])
    end

    def get_media_info(media_id, params = {})
      response = client.get_media_info(media_id, params)
      Media.from_info(response.body['photo'])
    end

    alias get_photo_info get_media_info
    alias get_video_info get_media_info

    def get_photo_sizes(photo_id, params = {})
      response = client.get_media_sizes(photo_id, params)
      Photo.from_sizes(response.body['sizes'])
    end
    def get_video_sizes(video_id, params = {})
      response = client.get_media_sizes(video_id, params)
      Video.from_sizes(response.body['sizes'])
    end

    def remove_media_tag(tag_id, params = {})
      client.remove_media_tag(tag_id, params)
    end
    alias remove_photo_tag remove_media_tag
    alias remove_video_tag remove_media_tag

    def search_media(search_params = {})
      response = client.search_media(search_params)
      Media.from_search(response.body['photos'])
    end
    def search_photos(search_params = {})
      search_media(search_params.merge(:media => 'photos'))
    end
    def search_videos(search_params = {})
      search_media(search_params.merge(:media => 'videos'))
    end

    #--
    # photos.upload
    def check_upload_tickets(tickets, params = {})
      tickets = tickets.join(',') if tickets.respond_to?(:join)
      response = client.check_upload_tickets(tickets, params)
      response.body['uploader']['ticket'].
        map { |info| Ticket.new(info) }
    end

    #--
    # licenses
    def get_licenses(params = {})
      response = client.get_licenses(params)
      License.from_hash(response.body['licenses']['license'])
    end

    #--
    # photosets
    def get_set_info(set_id, params = {})
      response = client.get_set_info(set_id, params)
      Set.from_info(response.body['photoset'])
    end

    def sets_from_user(user_nsid, params = {})
      response = client.sets_from_user(user_nsid, params)
      Set.from_user(response.body['photosets']['photoset'], user_nsid)
    end

    def media_from_set(set_id, params = {})
      response = client.media_from_set(set_id, params)
      Media.from_set(response.body['photoset'])
    end
    def photos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'photos'))
    end
    def videos_from_set(set_id, params = {})
      media_from_set(set_id, params.merge(:media => 'videos'))
    end
  end
end

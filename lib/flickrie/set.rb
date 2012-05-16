module Flickrie
  class Set
    def id()          @info['id']          end
    def secret()      @info['secret']      end
    def server()      @info['server']      end
    def farm()        @info['farm']        end
    def title()       @info['title']       end
    def description() @info['description'] end

    def primary_media_id() @info['primary'] end
    alias primary_photo_id primary_media_id
    alias primary_video_id primary_media_id

    def views_count()    Integer(@info['count_views'])    rescue nil end
    def comments_count() Integer(@info['count_comments']) rescue nil end
    def photos_count()   Integer(@info['count_photos'])   rescue nil end
    def videos_count()   Integer(@info['count_videos'])   rescue nil end
    def media_count
      photos_count + videos_count rescue nil
    end

    # Returns an instance of Flickrie::User
    def owner() User.new('nsid' => @info['owner']) if @info['owner'] end

    # Same as calling <tt>Flickrie.photos_from_set(set.id)</tt>
    def photos(params = {}) Flickrie.photos_from_set(id, params) end
    # Same as calling <tt>Flickrie.videos_from_set(set.id)</tt>
    def videos(params = {}) Flickrie.videos_from_set(id, params) end
    # Same as calling <tt>Flickrie.media_from_set(set.id)</tt>
    def media(params = {})  Flickrie.media_from_set(id, params)  end

    def can_comment?() Integer(@info['can_comment']) == 1 rescue nil end

    #--
    # TODO: Figure out what this is
    def needs_interstitial?() Integer(@info['needs_interstitial']) == 1 rescue nil end
    def visibility_can_see_set?() Integer(@info['visibility_can_see_set']) == 1 rescue nil end

    def created_at() Time.at(Integer(@info['date_create'])) rescue nil end
    def updated_at() Time.at(Integer(@info['date_update'])) rescue nil end

    def url
      "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}"
    end

    def [](key) @info[key] end
    def hash() @info end

    # Same as calling <tt>Flickrie.get_set_info(set.id)</tt>
    def get_info(info = nil)
      info ||= Flickrie.client.get_set_info(id).body['photoset']
      @info.update(info)

      # Fixes
      @info['title'] = @info['title']['_content']
      @info['description'] = @info['description']['_content']

      self
    end

    private

    def initialize(info = {})
      @info = info
    end

    def self.from_info(info)
      new.get_info(info)
    end

    def self.from_user(info, user_nsid)
      info.map do |info|
        info['count_photos'] = info.delete('photos')
        info['count_videos'] = info.delete('videos')
        info['title'] = info['title']['_content']
        info['description'] = info['description']['_content']
        info['owner'] = user_nsid

        new(info)
      end
    end
  end
end

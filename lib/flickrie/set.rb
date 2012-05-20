module Flickrie
  class Set
    # @!parse attr_reader :id
    def id()          @info['id']          end
    # @!parse attr_reader :secret
    def secret()      @info['secret']      end
    # @!parse attr_reader :server
    def server()      @info['server']      end
    # @!parse attr_reader :farm
    def farm()        @info['farm']        end
    # @!parse attr_reader :title
    def title()       @info['title']       end
    # @!parse attr_reader :description
    def description() @info['description'] end

    # @!parse attr_reader :primary_media_id
    def primary_media_id() @info['primary'] end
    alias primary_photo_id primary_media_id
    alias primary_video_id primary_media_id

    # @!parse attr_reader :views_count
    def views_count()    Integer(@info['count_views'])    rescue nil end
    # @!parse attr_reader :comments_count
    def comments_count() Integer(@info['count_comments']) rescue nil end
    # @!parse attr_reader :photos_count
    def photos_count()   Integer(@info['count_photos'])   rescue nil end
    # @!parse attr_reader :videos_count
    def videos_count()   Integer(@info['count_videos'])   rescue nil end
    # @!parse attr_reader :media_count
    def media_count
      photos_count + videos_count rescue nil
    end

    # @return [Flickrie::User]
    #
    # @!parse attr_reader :owner
    def owner() User.new('nsid' => @info['owner']) if @info['owner'] end

    # Same as calling `Flickrie.photos_from_set(set.id)`.
    def photos(params = {}) Flickrie.photos_from_set(id, params) end
    # Same as calling `Flickrie.videos_from_set(set.id)`.
    def videos(params = {}) Flickrie.videos_from_set(id, params) end
    # Same as calling `Flickrie.media_from_set(set.id)`.
    def media(params = {})  Flickrie.media_from_set(id, params)  end

    # @!parse attr_reader :can_comment?
    def can_comment?() Integer(@info['can_comment']) == 1 rescue nil end

    # @comment TODO: Figure out what this is
    # @!parse attr_reader :needs_interstitial?
    def needs_interstitial?() Integer(@info['needs_interstitial']) == 1 rescue nil end
    # @!parse attr_reader :visibility_can_see_set?
    def visibility_can_see_set?() Integer(@info['visibility_can_see_set']) == 1 rescue nil end

    # @!parse attr_reader :created_at
    def created_at() Time.at(Integer(@info['date_create'])) rescue nil end
    # @!parse attr_reader :updated_at
    def updated_at() Time.at(Integer(@info['date_update'])) rescue nil end

    # @!parse attr_reader :url
    def url
      "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}"
    end

    def [](key) @info[key] end
    # @!parse attr_reader :hash
    def hash() @info end

    # Same as calling `Flickrie.get_set_info(set.id)`
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

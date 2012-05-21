module Flickrie
  class Set
    # @!parse attr_reader \
    #   :id, :secret, :server, :farm, :title, :description,
    #   :primary_media_id, :views_count, :comments_count,
    #   :photos_count, :videos_count, :media_count, :owner,
    #   :can_comment?, :needs_interstitial?, :visibility_can_see_set?,
    #   :created_at, :updated_at, :url, :hash

    # @return [String]
    def id()          @info['id']          end
    # @return [String]
    def secret()      @info['secret']      end
    # @return [String]
    def server()      @info['server']      end
    # @return [Fixnum]
    def farm()        @info['farm']        end
    # @return [String]
    def title()       @info['title']       end
    # @return [String]
    def description() @info['description'] end

    # @return [String]
    def primary_media_id() @info['primary'] end
    alias primary_photo_id primary_media_id
    alias primary_video_id primary_media_id

    # @return [Fixnum]
    def views_count()    Integer(@info['count_views'])    rescue nil end
    # @return [Fixnum]
    def comments_count() Integer(@info['count_comments']) rescue nil end
    # @return [Fixnum]
    def photos_count()   Integer(@info['count_photos'])   rescue nil end
    # @return [Fixnum]
    def videos_count()   Integer(@info['count_videos'])   rescue nil end
    # @return [Fixnum]
    def media_count
      photos_count + videos_count rescue nil
    end

    # @return [Flickrie::User]
    def owner() User.new('nsid' => @info['owner']) if @info['owner'] end

    # Same as calling `Flickrie.photos_from_set(set.id)`.
    #
    # @return [Array<Flickrie::Photo>]
    def photos(params = {})
      Flickrie.photos_from_set(id, params)
    end
    # Same as calling `Flickrie.videos_from_set(set.id)`.
    #
    # @return [Array<Flickrie::Video>]
    def videos(params = {})
      Flickrie.videos_from_set(id, params)
    end
    # Same as calling `Flickrie.media_from_set(set.id)`.
    #
    # @return [Array<Flickrie::Photo, Flickrie::Video>]
    def media(params = {})
      Flickrie.media_from_set(id, params)
    end

    # @return [Boolean]
    def can_comment?() Integer(@info['can_comment']) == 1 rescue nil end

    # @return [Boolean]
    def needs_interstitial?() Integer(@info['needs_interstitial']) == 1 rescue nil end
    # @return [Boolean]
    def visibility_can_see_set?() Integer(@info['visibility_can_see_set']) == 1 rescue nil end

    # @return [Time]
    def created_at() Time.at(Integer(@info['date_create'])) rescue nil end
    # @return [Time]
    def updated_at() Time.at(Integer(@info['date_update'])) rescue nil end

    # @return [String]
    def url() "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}" rescue nil end

    def [](key) @info[key] end
    # @return [Hash]
    def hash() @info end

    # Same as calling `Flickrie.get_set_info(set.id)`
    #
    # @return [self]
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

module Flickrie
  class Set
    # @!parse attr_reader \
    #   :id, :secret, :server, :farm, :title, :description,
    #   :primary_media_id, :views_count, :comments_count,
    #   :photos_count, :videos_count, :media_count, :owner,
    #   :can_comment?, :needs_interstitial?, :visibility_can_see_set?,
    #   :created_at, :updated_at, :url, :hash

    # @return [String]
    def id()          @hash['id']          end
    # @return [String]
    def secret()      @hash['secret']      end
    # @return [String]
    def server()      @hash['server']      end
    # @return [Fixnum]
    def farm()        @hash['farm']        end
    # @return [String]
    def title()       @hash['title']       end
    # @return [String]
    def description() @hash['description'] end

    # @return [String]
    def primary_media_id() @hash['primary'] end
    alias primary_photo_id primary_media_id
    alias primary_video_id primary_media_id

    # @return [Fixnum]
    def views_count()    Integer(@hash['count_views'])    rescue nil end
    # @return [Fixnum]
    def comments_count() Integer(@hash['count_comments']) rescue nil end
    # @return [Fixnum]
    def photos_count()   Integer(@hash['count_photos'])   rescue nil end
    # @return [Fixnum]
    def videos_count()   Integer(@hash['count_videos'])   rescue nil end
    # @return [Fixnum]
    def media_count
      photos_count + videos_count rescue nil
    end

    # @return [Flickrie::User]
    def owner() User.new({'nsid' => @hash['owner']}, @api_caller) if @hash['owner'] end

    # Same as calling `Flickrie.photos_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    def photos(params = {})
      @api_caller.photos_from_set(id, params)
    end
    # Same as calling `Flickrie.videos_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    def videos(params = {})
      @api_caller.videos_from_set(id, params)
    end
    # Same as calling `Flickrie.media_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    def media(params = {})
      @api_caller.media_from_set(id, params)
    end

    # @return [Boolean]
    def can_comment?() Integer(@hash['can_comment']) == 1 rescue nil end

    # @return [Boolean]
    def needs_interstitial?() Integer(@hash['needs_interstitial']) == 1 rescue nil end
    # @return [Boolean]
    def visibility_can_see_set?() Integer(@hash['visibility_can_see_set']) == 1 rescue nil end

    # @return [Time]
    def created_at() Time.at(Integer(@hash['date_create'])) rescue nil end
    # @return [Time]
    def updated_at() Time.at(Integer(@hash['date_update'])) rescue nil end

    # @return [String]
    def url() "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}" rescue nil end

    def [](key) @hash[key] end
    # @return [Hash]
    def hash() @hash end

    # Same as calling `Flickrie.get_set_info(set.id)`
    #
    # @return [self]
    def get_info(params = {})
      @hash.deep_merge!(@api_caller.get_set_info(id, params).hash)
      self
    end

    private

    def initialize(hash, api_caller)
      @hash = hash
      @api_caller = api_caller
    end

    def self.new_collection(hash, api_caller)
      collection = hash.delete('photoset').map { |info| new(info, api_caller) }
      Collection.new(hash).replace(collection)
    end
  end
end

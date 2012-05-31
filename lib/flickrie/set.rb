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
    def owner() User.new('nsid' => @hash['owner']) if @hash['owner'] end

    # Same as calling `Flickrie.photos_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    def photos(params = {})
      Flickrie.photos_from_set(id, params)
    end
    # Same as calling `Flickrie.videos_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    def videos(params = {})
      Flickrie.videos_from_set(id, params)
    end
    # Same as calling `Flickrie.media_from_set(set.id)`.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    def media(params = {})
      Flickrie.media_from_set(id, params)
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
      hash ||= Flickrie.client.get_set_info(id, params).body['photoset']
      self.class.fix_info(hash)
      @hash.update(hash)

      self
    end

    private

    def initialize(hash = {})
      @hash = hash
    end

    def self.from_info(hash)
      fix_info(hash)
      new(hash)
    end

    def self.fix_info(hash)
      hash['title'] = hash['title']['_content']
      hash['description'] = hash['description']['_content']
    end

    def self.from_user(hash, user_nsid)
      collection = hash.delete('photoset').map do |set_hash|
        set_hash['count_photos'] = set_hash.delete('photos')
        set_hash['count_videos'] = set_hash.delete('videos')
        set_hash['title'] = set_hash['title']['_content']
        set_hash['description'] = set_hash['description']['_content']
        set_hash['owner'] = user_nsid

        new(set_hash)
      end

      Collection.new(hash).replace(collection)
    end
  end
end

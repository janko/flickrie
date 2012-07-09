require 'flickrie/objects/media/visibility'
require 'flickrie/objects/media/note'
require 'flickrie/objects/media/tag'
require 'flickrie/objects/media/exif'
require 'flickrie/objects/location'
require 'date'

module Flickrie
  module Media
    # @!parse attr_reader \
    #   :id, :secret, :server, :farm, :title, :description,
    #   :media_status, :path_alias, :camera, :exif, :views_count,
    #   :comments_count, :location, :geo_permissions, :tags,
    #   :machine_tags, :license, :posted_at, :uploaded_at,
    #   :updated_at, :taken_at, :taken_at_granularity, :owner,
    #   :safety_level, :safe?, :moderate?, :restricted?,
    #   :url, :visibility, :primary?, :favorite?, :can_comment?,
    #   :can_add_meta?, :can_everyone_comment?, :can_everyone_add_meta?,
    #   :can_download?, :can_blog?, :can_print?, :can_share?,
    #   :has_people?, :faved?, :notes, :favorites, :hash, :short_url

    # @return [String]
    def id()             @hash['id']           end
    # @return [String]
    def secret()         @hash['secret']       end
    # @return [String]
    def server()         @hash['server']       end
    # @return [Fixnum]
    def farm()           @hash['farm']         end
    # @return [String]
    def title()          @hash['title']        end
    # @return [String]
    def description()    @hash['description']  end
    # @return [String]
    def media_status()   @hash['media_status'] end
    # @return [String]
    def path_alias()     @hash['pathalias']    end

    # @return [String]
    def camera() @hash['camera'] end
    # Returns exif of the photo/video. Example:
    #
    #     photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #     photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #     photo.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @return [Flickrie::Media::Exif]
    def exif() Exif.new(@hash['exif']) rescue nil end

    # @return [Fixnum]
    def views_count()    Integer(@hash['views'])          rescue nil end
    # @return [Fixnum]
    def comments_count() Integer(@hash['comments_count']) rescue nil end

    # @return [Flickrie::Location]
    def location() Location.new(@hash['location']) rescue nil end
    # @return [Flickrie::Media::Visibility]
    def geo_permissions() Visibility.new(@hash['geoperms']) rescue nil end

    # @return [Array<Flickrie::Media::Tag>]
    def tags() @hash['tags'].map { |info| Tag.new(info, @api_caller) }     rescue nil end
    # @return [Array<Flickrie::Media::Tag>]
    def machine_tags() tags.select { |tag| tag.machine_tag? } rescue nil end

    # @return [Flickrie::License]
    def license() License.new(@hash['license']) rescue nil end

    # @return [Time]
    def posted_at()   Time.at(Integer(@hash['dates']['posted']))           rescue nil end
    # @return [Time]
    def uploaded_at() Time.at(Integer(@hash['dates']['uploaded']))         rescue nil end
    # @return [Time]
    def updated_at()  Time.at(Integer(@hash['dates']['lastupdate']))       rescue nil end
    # @return [Time]
    def taken_at()    DateTime.parse(@hash['dates']['taken']).to_time      rescue nil end
    # @return [Fixnum]
    def taken_at_granularity() Integer(@hash['dates']['takengranularity']) rescue nil end

    # @return [Flickrie::User]
    def owner() User.new(@hash['owner'], @api_caller) if @hash['owner'] end

    # @return [Fixnum]
    def safety_level() Integer(@hash['safety_level']) rescue nil end

    # @return [Boolean]
    def safe?()       safety_level <= 1 if safety_level end
    # @return [Boolean]
    def moderate?()   safety_level == 2 if safety_level end
    # @return [Boolean]
    def restricted?() safety_level == 3 if safety_level end

    # @return [String]
    def url
      if owner and id
        "http://www.flickr.com/photos/#{owner.nsid}/#{id}"
      elsif @hash['url']
        "http://www.flickr.com" + @hash['url']
      end
    end
    # @return [String]
    def short_url
      "http://flic.kr/p/#{to_base58(id)}" rescue nil
    end

    # @return [Flickrie::Media::Visibility]
    def visibility() Visibility.new(@hash['visibility']) rescue nil end

    # @return [Boolean]
    def primary?() Integer(@hash['isprimary']) == 1 rescue nil end

    # @return [Boolean]
    def favorite?() Integer(@hash['isfavorite']) == 1 rescue nil end

    # @return [Boolean]
    def can_comment?()  Integer(@hash['editability']['cancomment']) == 1 rescue nil end
    # @return [Boolean]
    def can_add_meta?() Integer(@hash['editability']['canaddmeta']) == 1 rescue nil end

    # @return [Boolean]
    def can_everyone_comment?()  Integer(@hash['publiceditability']['cancomment']) == 1 rescue nil end
    # @return [Boolean]
    def can_everyone_add_meta?() Integer(@hash['publiceditability']['canaddmeta']) == 1 rescue nil end

    # @return [Boolean]
    def can_download?() Integer(@hash['usage']['candownload']) == 1 rescue nil end
    # @return [Boolean]
    def can_blog?()     Integer(@hash['usage']['canblog']) == 1     rescue nil end
    # @return [Boolean]
    def can_print?()    Integer(@hash['usage']['canprint']) == 1    rescue nil end
    # @return [Boolean]
    def can_share?()    Integer(@hash['usage']['canshare']) == 1    rescue nil end

    # @return [Boolean]
    def commenting_permissions()  Integer(@hash['permissions']['permcomment']) rescue nil end
    # @return [Boolean]
    def adding_meta_permissions() Integer(@hash['permissions']['permaddmeta']) rescue nil end

    # @return [Boolean]
    def has_people?() Integer(@hash['people']['haspeople']) == 1 rescue nil end

    # @return [Boolean]
    def faved?() Integer(@hash['is_faved']) == 1 rescue nil end

    # @return [Array<Flickrie::Media::Note>]
    def notes() @hash['notes']['note'].map { |info| Note.new(info, @api_caller) } rescue nil end

    # @return [Integer]
    def content_type() Integer(@hash['content_type']) rescue nil end

    # @return [Flickrie::Collection<Flickrie::User>]
    def favorites
      collection = @hash['person'].map { |info| User.new(info, @api_caller) }
      Collection.new(@hash).replace(collection)
    rescue
      nil
    end

    def [](key) @hash[key] end
    # Returns the raw hash from the response. Useful if something isn't available by methods.
    #
    # @return [Hash]
    def hash() @hash end

    # Same as calling `Flickrie.get_(photo|video)_info(id)`.
    #
    # @return [self]
    def get_info(params = {})
      @hash.deep_merge!(@api_caller.send("get_#{media_type}_info", id, params).hash)
      self
    end

    # Same as calling `Flickrie.get_(photo|video)_exif(id)`.
    #
    # @return [self]
    def get_exif(params = {})
      @hash.deep_merge!(@api_caller.send("get_#{media_type}_exif", id, params).hash)
      self
    end

    # Same as calling `Flickrie.get_(photo|video)_favorites(id)`.
    #
    # @return [self]
    def get_favorites(params = {})
      @hash.deep_merge!(@api_caller.send("get_#{media_type}_favorites", id, params).hash)
      self
    end

    def initialize(hash, api_caller)
      @hash = hash
      @api_caller = api_caller
    end

    private

    def media_type
      self.class.name.split('::').last.downcase
    end

    module ClassMethods
      def new_collection(hash, api_caller)
        collection = hash.delete('photo').map { |info| new(info, api_caller) }
        Collection.new(hash).replace(collection)
      end
    end
    extend ClassMethods

    # @private
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # @private
    def self.new(hash, api_caller)
      eval(hash['media'].capitalize).new(hash, api_caller)
    end

    include Base58
  end
end

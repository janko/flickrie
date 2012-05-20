require 'flickrie/media/visibility'
require 'flickrie/media/note'
require 'flickrie/media/tag'
require 'flickrie/media/exif'
require 'flickrie/location'
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
    #   :has_people?, :faved?, :notes, :favorites, :hash

    # @return [String]
    def id()             @info['id']           end
    # @return [String]
    def secret()         @info['secret']       end
    # @return [String]
    def server()         @info['server']       end
    # @return [Fixnum]
    def farm()           @info['farm']         end
    # @return [String]
    def title()          @info['title']        end
    # @return [String]
    def description()    @info['description']  end
    # @return [String]
    def media_status()   @info['media_status'] end
    # @return [String]
    def path_alias()     @info['pathalias']    end

    # @return [String]
    def camera() @info['camera'] end
    # Returns exif of the photo/video. Example:
    #
    #     photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #     photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #     photo.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @return [Flickrie::Media::Exif]
    def exif() Exif.new(@info['exif']) rescue nil end

    # @return [Fixnum]
    def views_count()    Integer(@info['views'])          rescue nil end
    # @return [Fixnum]
    def comments_count() Integer(@info['comments_count']) rescue nil end

    # @return [Flickrie::Location]
    def location() Location.new(@info['location']) rescue nil end
    # @return [Flickrie::Media::Visibility]
    def geo_permissions() Visibility.new(@info['geoperms']) rescue nil end

    # @return [Array<Flickrie::Media::Tag>]
    def tags() @info['tags'].map { |info| Tag.new(info) }     rescue nil end
    # @return [Array<Flickrie::Media::Tag>]
    def machine_tags() tags.select { |tag| tag.machine_tag? } rescue nil end

    # @return [Flickrie::License]
    def license() License.new(@info['license']) rescue nil end

    # @return [Time]
    def posted_at()   Time.at(Integer(@info['dates']['posted']))           rescue nil end
    # @return [Time]
    def uploaded_at() Time.at(Integer(@info['dates']['uploaded']))         rescue nil end
    # @return [Time]
    def updated_at()  Time.at(Integer(@info['dates']['lastupdate']))       rescue nil end
    # @return [Time]
    def taken_at()    DateTime.parse(@info['dates']['taken']).to_time      rescue nil end
    # @return [Fixnum]
    def taken_at_granularity() Integer(@info['dates']['takengranularity']) rescue nil end

    # @return [Flickrie::User]
    def owner() User.new(@info['owner']) rescue nil end

    # @return [Fixnum]
    def safety_level() Integer(@info['safety_level']) rescue nil end

    # @return [Boolean]
    def safe?()       safety_level <= 1 if safety_level end
    # @return [Boolean]
    def moderate?()   safety_level == 2 if safety_level end
    # @return [Boolean]
    def restricted?() safety_level == 3 if safety_level end

    # @comment TODO: Take care about the url from #get_info
    # @return [String]
    def url
      if owner and id
        "http://www.flickr.com/photos/#{owner.nsid}/#{id}"
      elsif @info['url']
        "http://www.flickr.com" + @info['url']
      end
    end

    # @return [Flickrie::Media::Visibility]
    def visibility() Visibility.new(@info['visibility']) rescue nil end

    # @return [Boolean]
    def primary?() Integer(@info['isprimary']) == 1 rescue nil end

    # @return [Boolean]
    def favorite?() Integer(@info['isfavorite']) == 1 rescue nil end

    # @return [Boolean]
    def can_comment?()  Integer(@info['editability']['cancomment']) == 1 rescue nil end
    # @return [Boolean]
    def can_add_meta?() Integer(@info['editability']['canaddmeta']) == 1 rescue nil end

    # @return [Boolean]
    def can_everyone_comment?()  Integer(@info['publiceditability']['cancomment']) == 1 rescue nil end
    # @return [Boolean]
    def can_everyone_add_meta?() Integer(@info['publiceditability']['canaddmeta']) == 1 rescue nil end

    # @return [Boolean]
    def can_download?() Integer(@info['usage']['candownload']) == 1 rescue nil end
    # @return [Boolean]
    def can_blog?()     Integer(@info['usage']['canblog']) == 1     rescue nil end
    # @return [Boolean]
    def can_print?()    Integer(@info['usage']['canprint']) == 1    rescue nil end
    # @return [Boolean]
    def can_share?()    Integer(@info['usage']['canshare']) == 1    rescue nil end

    # @return [Boolean]
    def has_people?() Integer(@info['people']['haspeople']) == 1 rescue nil end

    # @return [Boolean]
    def faved?() Integer(@info['is_faved']) == 1 rescue nil end

    # @return [Array<Flickrie::Media::Note>]
    def notes() @info['notes']['note'].map { |hash| Note.new(hash) } rescue nil end

    # @return [Array<Flickrie::User>]
    def favorites() @info['person'].map { |info| User.new(info) } rescue nil end

    def [](key) @info[key] end
    # Returns the raw hash from the response. Useful if something isn't available by methods.
    #
    # @return [Hash]
    def hash() @info end

    # Same as calling `Flickrie.get_(photo|video)_info(id)`.
    #
    # @return [self]
    def get_info(params = {}, info = nil)
      info ||= Flickrie.client.get_media_info(id, params).body['photo']
      @info.update(info)

      # Fixes
      @info['title'] = @info['title']['_content']
      @info['description'] = @info['description']['_content']
      @info['comments_count'] = @info.delete('comments')['_content']
      @info['dates']['uploaded'] = @info.delete('dateuploaded')
      @info['tags'] = @info['tags']['tag']

      self
    end

    # Same as calling `Flickrie.get_(photo|video)_info(id)`.
    #
    # @return [self]
    def get_exif(params = {}, info = nil)
      info ||= Flickrie.client.get_media_exif(id, params).body['photo']
      @info.update(info)

      self
    end

    # Same as calling `Flickrie.get_(photo|video)_info(id)`.
    #
    # @return [self]
    def get_favorites(params = {}, info = nil)
      info ||= Flickrie.client.get_media_favorites(id, params).body['photo']
      @info.update(info)

      self
    end

    def initialize(info = {})
      @info = info
    end

    # @private
    module ClassMethods
      def from_set(hash)
        hash['photo'].map do |info|
          info['owner'] = {
            'nsid' => hash['owner'],
            'username' => hash['ownername'],
            'iconserver' => info.delete('iconserver'),
            'iconfarm' => info.delete('iconfarm')
          }
          if info['place_id']
            geo_info = %w[latitude longitude accuracy context place_id woeid]
            info['location'] = geo_info.inject({}) do |location, geo|
              location.update(geo => info.delete(geo))
            end
            info['geoperms'] = {
              'isfamily' => info['geo_is_family'],
              'isfriend' => info['geo_is_friend'],
              'iscontact' => info['geo_is_contact'],
              'ispublic' => info['geo_is_public']
            }
          end
          info['dates'] = {
            'uploaded' => info.delete('dateupload'),
            'lastupdate' => info.delete('lastupdate'),
            'taken' => info.delete('datetaken'),
            'takengranularity' => info.delete('datetakengranularity'),
          }

          unless info['tags'].nil?
            info['tags'] = info['tags'].split(' ').map do |tag_content|
              {'_content' => tag_content, 'machine_tag' => 0}
            end
          end
          unless info['machine_tags'].nil?
            info['tags'] ||= []
            info['tags'] += info.delete('machine_tags').split(' ').map do |tag_content|
              {'_content' => tag_content, 'machine_tag' => 1}
            end
          end

          new(info)
        end
      end

      def from_info(info)
        new('media' => info['media']).get_info({}, info)
      end

      def from_user(hash)
        if hash['photo'].first
          hash['owner'] = hash['photo'].first['owner']
          hash['ownername'] = hash['photo'].first['ownername']
        end
        hash['photo'].each do |info|
          info['visibility'] = {
            'ispublic' => info.delete('ispublic'),
            'isfriend' => info.delete('isfriend'),
            'isfamily' => info.delete('isfamily')
          }
        end

        from_set(hash)
      end

      def from_sizes(info)
        new.get_sizes({}, info)
      end

      def from_search(hash)
        from_user(hash)
      end

      def from_contacts(hash)
        hash['photo'].each do |info|
          info['ownername'] = info.delete('username')
        end

        from_user(hash)
      end

      def from_context(hash)
        count = hash['count']['_content'].to_i
        previous_photo = new(hash['prevphoto']) rescue nil
        next_photo = new(hash['nextphoto']) rescue nil
        Struct.new(:count, :previous, :next).new \
          count, previous_photo, next_photo
      end

      def from_exif(info)
        new.get_exif({}, info)
      end
    end
    extend(ClassMethods)

    # @private
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # @private
    def self.new(info)
      eval(info['media'].capitalize).new(info)
    end
  end
end

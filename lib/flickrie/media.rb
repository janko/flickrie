require 'flickrie/media/visibility'
require 'flickrie/media/note'
require 'flickrie/media/tag'
require 'flickrie/media/exif'
require 'flickrie/location'
require 'date'

module Flickrie
  module Media
    def id()             @info['id']           end
    def secret()         @info['secret']       end
    def server()         @info['server']       end
    def farm()           @info['farm']         end
    def title()          @info['title']        end
    def description()    @info['description']  end
    def media_status()   @info['media_status'] end
    def path_alias()     @info['pathalias']    end

    def camera() @info['camera'] end
    # ==== Example
    #
    #   photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #   photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #   photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #   photo.exif.get('X-Resolution')                   # => '180 dpi'
    def exif() Exif.new(@info['exif']) rescue nil end

    def views_count()    Integer(@info['views'])          rescue nil end
    def comments_count() Integer(@info['comments_count']) rescue nil end

    # Returns an instance of Flickrie::Location
    def location() Location.new(@info['location']) rescue nil end
    # Returns an instance of Flickrie::Media::Visibility
    def geo_permissions() Visibility.new(@info['geoperms']) rescue nil end

    # Returns an array of Flickrie::Media::Tag
    def tags() @info['tags'].map { |info| Tag.new(info) }     rescue nil end
    # Returns an array of Flickrie::Media::Tag
    def machine_tags() tags.select { |tag| tag.machine_tag? } rescue nil end

    # Returns an instance of Flickrie::License
    def license() License.new(@info['license']) rescue nil end

    def posted_at()   Time.at(Integer(@info['dates']['posted']))           rescue nil end
    def uploaded_at() Time.at(Integer(@info['dates']['uploaded']))         rescue nil end
    def updated_at()  Time.at(Integer(@info['dates']['lastupdate']))       rescue nil end
    def taken_at()    DateTime.parse(@info['dates']['taken']).to_time      rescue nil end
    def taken_at_granularity() Integer(@info['dates']['takengranularity']) rescue nil end

    # Returns an instance of Flickrie::User
    def owner() User.new(@info['owner']) rescue nil end

    def safety_level() Integer(@info['safety_level']) rescue nil end

    def safe?()       safety_level <= 1 if safety_level end
    def moderate?()   safety_level == 2 if safety_level end
    def restricted?() safety_level == 3 if safety_level end

    #--
    # TODO: Take care about the url from #get_info
    def url
      if owner and id
        "http://www.flickr.com/photos/#{owner.nsid}/#{id}"
      elsif @info['url']
        "http://www.flickr.com" + @info['url']
      end
    end

    # Returns an instance of Flickrie::Media::Visibility
    def visibility() Visibility.new(@info['visibility']) rescue nil end

    def primary?() Integer(@info['isprimary']) == 1 rescue nil end

    def favorite?() Integer(@info['isfavorite']) == 1 rescue nil end

    def can_comment?()  Integer(@info['editability']['cancomment']) == 1 rescue nil end
    def can_add_meta?() Integer(@info['editability']['canaddmeta']) == 1 rescue nil end

    def can_everyone_comment?()  Integer(@info['publiceditability']['cancomment']) == 1 rescue nil end
    def can_everyone_add_meta?() Integer(@info['publiceditability']['canaddmeta']) == 1 rescue nil end

    def can_download?() Integer(@info['usage']['candownload']) == 1 rescue nil end
    def can_blog?()     Integer(@info['usage']['canblog']) == 1     rescue nil end
    def can_print?()    Integer(@info['usage']['canprint']) == 1    rescue nil end
    def can_share?()    Integer(@info['usage']['canshare']) == 1    rescue nil end

    def has_people?() Integer(@info['people']['haspeople']) == 1 rescue nil end

    def faved?() Integer(@info['is_faved']) == 1 rescue nil end

    # Returns an array of Flickrie::Media::Note
    def notes() @info['notes']['note'].map { |hash| Note.new(hash) } rescue nil end

    # Returns an array of Flickrie::User
    def favorites() @info['person'].map { |info| User.new(info) } rescue nil end

    def [](key) @info[key] end
    def hash() @info end

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

    def get_exif(params = {}, info = nil)
      info ||= Flickrie.client.get_media_exif(id, params).body['photo']
      @info.update(info)

      self
    end

    def get_favorites(params = {}, info = nil)
      info ||= Flickrie.client.get_media_favorites(id, params).body['photo']
      @info.update(info)

      self
    end

    def initialize(info = {})
      @info = info
    end

    module ClassMethods # :nodoc:
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

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def self.new(info)
      eval(info['media'].capitalize).new(info)
    end
  end
end

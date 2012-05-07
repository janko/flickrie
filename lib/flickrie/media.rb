require 'flickrie/media/visibility'
require 'flickrie/media/note'
require 'flickrie/media/tag'
require 'flickrie/media/ticket'
require 'flickrie/media/exif'
require 'flickrie/location'
require 'date'

module Flickrie
  module Media
    def id;             @info['id']           end
    def secret;         @info['secret']       end
    def server;         @info['server']       end
    def farm;           @info['farm']         end
    def title;          @info['title']        end
    def description;    @info['description']  end
    def tags;           @info['tags']         end
    def media_status;   @info['media_status'] end
    def path_alias;     @info['pathalias']    end
    def camera;         @info['camera']       end
    # ==== Example
    #
    #   photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #   photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
    #   photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
    #   photo.exif.get('X-Resolution')                   # => '180 dpi'
    #
    def exif;           @info['exif']         end

    def views_count
      @info['views'].to_i if @info['views']
    end

    def comments_count
      @info['comments_count'].to_i if @info['comments_count']
    end

    def location
      Location.new(@info['location']) if @info['location']
    end

    def machine_tags
      tags.select { |tag| tag.machine_tag? } if tags
    end

    def geo_permissions
      if @info['geoperms']
        Visibility.new \
          *[@info['geoperms']['ispublic'],
            @info['geoperms']['isfriend'],
            @info['geoperms']['isfamily'],
            @info['geoperms']['iscontact']]
      end
    end

    def license
      License.new(@info['license']) if @info['license']
    end

    def posted_at;   Time.at(@info['dates']['posted'].to_i) if @info['dates']['posted']         end
    def uploaded_at; Time.at(@info['dates']['uploaded'].to_i) if @info['dates']['uploaded']     end
    def updated_at;  Time.at(@info['dates']['lastupdate'].to_i) if @info['dates']['lastupdate'] end
    def taken_at;    DateTime.parse(@info['dates']['taken']).to_time if @info['dates']['taken'] end

    def taken_at_granularity
      @info['dates']['takengranularity'].to_i if @info['dates']['takengranularity']
    end

    def owner
      User.new(@info['owner']) if @info['owner']
    end

    def safety_level; @info['safety_level'].to_i if @info['safety_level'] end

    def safe?;       safety_level <= 1 if safety_level end
    def moderate?;   safety_level == 2 if safety_level end
    def restricted?; safety_level == 3 if safety_level end

    def url
      if owner and id
        "http://www.flickr.com/photos/#{owner.nsid}/#{id}"
      elsif @info['url']
        "http://www.flickr.com" + @info['url']
      end
    end

    def visibility
      if @info['visibility']
        Visibility.new \
          *[@info['visibility']['ispublic'],
            @info['visibility']['isfriend'],
            @info['visibility']['isfamily']]
      end
    end

    def primary?; @info['isprimary'].to_i == 1 if @info['isprimary'] end

    def favorite?; @info['isfavorite'].to_i == 1 if @info['isfavorite'] end

    def can_comment?;  @info['editability']['cancomment'].to_i == 1 if @info['editability'] end
    def can_add_meta?; @info['editability']['canaddmeta'].to_i == 1 if @info['editability'] end

    def can_everyone_comment?
      @info['publiceditability']['cancomment'].to_i == 1 if @info['publiceditability']
    end

    def can_everyone_add_meta?
      @info['publiceditability']['canaddmeta'].to_i == 1 if @info['publiceditability']
    end

    def can_download?; @info['usage']['candownload'].to_i == 1 if @info['usage']['candownload'] end
    def can_blog?;     @info['usage']['canblog'].to_i == 1     if @info['usage']['canblog']     end
    def can_print?;    @info['usage']['canprint'].to_i == 1    if @info['usage']['canprint']    end
    def can_share?;    @info['usage']['canshare'].to_i == 1    if @info['usage']['canshare']    end

    def has_people?; @info['people']['haspeople'].to_i == 1 if @info['people'] end

    def faved?; @info['is_faved'].to_i == 1 if @info['is_faved'] end

    def notes
      @info['notes']['note'].map { |hash| Note.new(hash) } if @info['notes']
    end

    def [](key)
      @info[key]
    end

    def get_info(info = nil)
      info ||= Flickrie.client.get_media_info(id).body['photo']

      info['title'] = info['title']['_content']
      info['description'] = info['description']['_content']
      info['comments_count'] = info.delete('comments')['_content']
      info['dates']['uploaded'] = info.delete('dateuploaded')
      info['tags'] = info['tags']['tag'].map { |info| Tag.new(info) }

      @info.update(info)
      self
    end

    def get_exif(params = {}, info = nil)
      info ||= Flickrie.client.get_media_exif(id, params).body['photo']

      @info['camera'] = info['camera'] unless info['camera'].empty?
      @info['exif'] = Exif.new(info['exif']) unless info['exif'].empty?

      self
    end

    def initialize(info = {})
      @info = info
      @info['dates'] ||= {}
      @info['usage'] ||= {}
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
          info['usage'] = {}

          unless info['tags'].nil?
            info['tags'] = info['tags'].split(' ').map do |tag_content|
              Tag.new('_content' => tag_content)
            end
          end

          new(info)
        end
      end

      def from_info(info)
        new('media' => info['media']).get_info(info)
      end

      def from_user(hash)
        hash['owner'] = hash['photo'].first['owner']
        hash['ownername'] = hash['photo'].first['ownername']
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
        new.get_sizes(info)
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
        hash['count'] = hash['count']['_content'].to_i

        ['prevphoto', 'nextphoto'].each do |media|
          unless hash[media]['media'].nil?
            hash[media] = new(hash[media])
          else
            hash[media] = nil
          end
        end

        hash
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

module Flickrie
  module Media
    # @private
    module ClassMethods
      def from_set(hash)
        collection = hash.delete('photo').map do |media_hash|
          media_hash['owner'] = {
            'id' => hash['owner'],
            'nsid' => hash['owner'],
            'username' => hash['ownername'],
          }
          fix_extras(media_hash)
          new(media_hash)
        end

        Collection.new(hash).replace(collection)
      end

      def from_info(hash)
        fix_info(hash)
        new(hash)
      end

      def from_user(hash)
        collection = hash.delete('photo').map do |media_hash|
          media_hash['owner'] = {
            'id' => media_hash['owner'],
            'nsid' => media_hash.delete('owner'),
            'username' => media_hash.delete('ownername')
          }
          fix_extras(media_hash)
          fix_visibility(media_hash)
          new(media_hash)
        end

        Collection.new(hash).replace(collection)
      end

      def from_sizes(hash)
        fix_sizes(hash)
        new(hash)
      end

      def from_search(hash)
        from_user(hash)
      end

      def from_contacts(hash)
        hash['photo'].each do |media_hash|
          media_hash['ownername'] = media_hash.delete('username')
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

      def from_not_in_set(hash)
        from_user(hash)
      end

      def of_user(hash)
        from_user(hash)
      end

      def from_perms(hash)
        fix_visibility(hash)
        hash['permissions'] = {
          'permcomment' => hash.delete('permcomment'),
          'permaddmeta' => hash.delete('permaddmeta')
        }
        new(hash)
      end

      def from_recent(hash)
        from_user(hash)
      end

      def from_untagged(hash)
        from_user(hash)
      end

      def from_geo_data(hash)
        from_user(hash)
      end

      def from_recently_updated(hash)
        from_user(hash)
      end

    private

      def fix_extras(hash)
        if hash['iconserver'] or hash['iconfarm']
          hash['owner'] ||= {}
          hash['owner'].update \
            'iconserver' => hash.delete('iconserver'),
            'iconfarm' => hash.delete('iconfarm')
        end

        if hash['place_id']
          geo_info = %w[latitude longitude accuracy context place_id woeid]
          hash['location'] = geo_info.inject({}) do |location, geo|
            location.update(geo => hash.delete(geo))
          end
          hash['geoperms'] = {
            'isfamily' => hash['geo_is_family'],
            'isfriend' => hash['geo_is_friend'],
            'iscontact' => hash['geo_is_contact'],
            'ispublic' => hash['geo_is_public']
          }
        end

        if hash['tags']
          hash['tags'] = hash['tags'].split(' ').map do |tag_content|
            {'_content' => tag_content, 'machine_tag' => 0}
          end
        end
        if hash['machine_tags']
          hash['tags'] ||= []
          hash['tags'] += hash.delete('machine_tags').split(' ').map do |tag_content|
            {'_content' => tag_content, 'machine_tag' => 1}
          end
        end

        hash['dates'] = {
          'uploaded' => hash.delete('dateupload'),
          'lastupdate' => hash.delete('lastupdate'),
          'taken' => hash.delete('datetaken'),
          'takengranularity' => hash.delete('datetakengranularity'),
        }

        hash
      end

      def fix_info(hash)
        hash['title'] = hash['title']['_content']
        hash['description'] = hash['description']['_content']
        hash['comments_count'] = hash.delete('comments')['_content']
        hash['dates']['uploaded'] = hash.delete('dateuploaded')
        hash['tags'] = hash['tags']['tag']

        hash
      end

      def fix_visibility(hash)
        hash['visibility'] = {
          'ispublic' => hash.delete('ispublic'),
          'isfriend' => hash.delete('isfriend'),
          'isfamily' => hash.delete('isfamily')
        }
      end

      def fix_sizes(hash)
        case self.name.split('::').last
        when "Photo"
          hash['usage'] = {
            'canblog'     => hash['canblog'],
            'canprint'    => hash['canprint'],
            'candownload' => hash['candownload']
          }
          flickr_sizes = {
            'Square'       => Photo::FLICKR_SIZES['Square 75'],
            'Large Square' => Photo::FLICKR_SIZES['Square 150'],
            'Thumbnail'    => Photo::FLICKR_SIZES['Thumbnail'],
            'Small'        => Photo::FLICKR_SIZES['Small 240'],
            'Small 320'    => Photo::FLICKR_SIZES['Small 320'],
            'Medium'       => Photo::FLICKR_SIZES['Medium 500'],
            'Medium 640'   => Photo::FLICKR_SIZES['Medium 640'],
            'Medium 800'   => Photo::FLICKR_SIZES['Medium 800'],
            'Large'        => Photo::FLICKR_SIZES['Large 1024'],
            'Large 1600'   => Photo::FLICKR_SIZES['Large 1600'],
            'Large 2048'   => Photo::FLICKR_SIZES['Large 2048'],
            'Original'     => Photo::FLICKR_SIZES['Original']
          }
          hash['size'].each do |size_info|
            size_abbr = flickr_sizes[size_info['label']]
            hash["width_#{size_abbr}"] = size_info['width']
            hash["height_#{size_abbr}"] = size_info['height']
            hash["url_#{size_abbr}"] = size_info['source']
          end
        when "Video"
          hash['usage'] = {
            'canblog'     => hash['canblog'],
            'canprint'    => hash['canprint'],
            'candownload' => hash['candownload']
          }
          hash['video'] ||= {}
          hash['size'].each do |info|
            case info['label']
            when 'Video Player' then hash['video']['source_url'] = info['source']
            when 'Site MP4'     then hash['video']['download_url'] = info['source']
            when 'Mobile MP4'   then hash['video']['mobile_download_url'] = info['source']
            end
          end
        end
      end
    end
    extend(ClassMethods)

    # @private
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # @private
    def self.new(hash)
      eval(hash['media'].capitalize).new(hash)
    end
  end
end

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

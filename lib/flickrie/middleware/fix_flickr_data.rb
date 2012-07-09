module Flickrie
  module Middleware
    class FixFlickrData < Faraday::Response::Middleware
      def call(env)
        response = @app.call(env)
        fix_flickr_data!(response)
        response
      end

      private

      # Ugly, just normalizing the data
      def fix_flickr_data!(response)
        data = response.env[:body]
        query = CGI.parse(response.env[:url].query)
        flickr_method = query['method'].first

        case flickr_method
        # people
        when 'flickr.people.findByUsername'
          data['user']['username'] = data['user']['username']['_content']
        when 'flickr.people.findByEmail'
          data['user']['username'] = data['user']['username']['_content']
        when 'flickr.people.getInfo'
          %w[username realname location description profileurl mobileurl photosurl].each do |attribute|
            data['person'][attribute] = data['person'][attribute]['_content']
          end
          %w[count firstdatetaken firstdate].each do |photo_attribute|
            data['person']['photos'][photo_attribute] = data['person']['photos'][photo_attribute]['_content']
          end
        when 'flickr.test.login'
          data['user']['username'] = data['user']['username']['_content']
        when 'flickr.people.getUploadStatus'
          data['user']['username'] = data['user']['username']['_content']
          data['user']['upload_status'] = {
            'bandwidth' => data['user'].delete('bandwidth'),
            'filesize' => data['user'].delete('filesize'),
            'sets' => data['user'].delete('sets'),
            'videosize' => data['user'].delete('videosize'),
            'videos' => data['user'].delete('videos')
          }

        # photos
        when 'flickr.people.getPhotos'
          fix_common!(data)
        when 'flickr.people.getPublicPhotos'
          fix_common!(data)
        when 'flickr.photos.getInfo'
          data['photo']['title'] = data['photo']['title']['_content']
          data['photo']['description'] = data['photo']['description']['_content']
          data['photo']['comments_count'] = data['photo'].delete('comments')['_content']
          data['photo']['dates']['uploaded'] = data['photo'].delete('dateuploaded')
          data['photo']['tags'] = data['photo']['tags']['tag']
        when 'flickr.photosets.getPhotos'
          data['photoset']['photo'].map! do |media_hash|
            media_hash['owner'] = {
              'id' => data['photoset']['owner'],
              'nsid' => data['photoset']['owner'],
              'username' => data['photoset']['ownername'],
            }
            fix_extras!(media_hash)
            media_hash
          end
        when 'flickr.photos.getSizes'
          data['sizes']['usage'] = {
            'canblog'     => data['sizes']['canblog'],
            'canprint'    => data['sizes']['canprint'],
            'candownload' => data['sizes']['candownload']
          }
          data['sizes']['id'] = query['photo_id'].first
          if data['sizes']['size'].find { |hash| hash['label'] == 'Video Player' }
            # Video
            data['sizes']['video'] ||= {}
            data['sizes']['size'].each do |info|
              case info['label']
              when 'Video Player' then data['sizes']['video']['source_url'] = info['source']
              when 'Site MP4'     then data['sizes']['video']['download_url'] = info['source']
              when 'Mobile MP4'   then data['sizes']['video']['mobile_download_url'] = info['source']
              end
            end
          else
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
            data['sizes']['size'].each do |size_info|
              size_abbr = flickr_sizes[size_info['label']]
              data['sizes']["width_#{size_abbr}"] = size_info['width']
              data['sizes']["height_#{size_abbr}"] = size_info['height']
              data['sizes']["url_#{size_abbr}"] = size_info['source']
            end
          end
        when 'flickr.photos.search'
          fix_common!(data)
        when 'flickr.photos.getContactsPhotos'
          data['photos']['photo'].each do |media_hash|
            media_hash['ownername'] = media_hash.delete('username')
          end
          fix_common!(data)
        when 'flickr.photos.getContactsPublicPhotos'
          data['photos']['photo'].each do |media_hash|
            media_hash['ownername'] = media_hash.delete('username')
          end
          fix_common!(data)
        when 'flickr.photos.getNotInSet'
          fix_common!(data)
        when 'flickr.people.getPhotosOf'
          fix_common!(data)
        when 'flickr.photos.getPerms'
          fix_visibility!(data['perms'])
          data['perms']['permissions'] = {
            'permcomment' => data['perms'].delete('permcomment'),
            'permaddmeta' => data['perms'].delete('permaddmeta')
          }
        when 'flickr.photos.getRecent'
          fix_common!(data)
        when 'flickr.photos.getUntagged'
          fix_common!(data)
        when 'flickr.photos.getWithGeoData'
          fix_common!(data)
        when 'flickr.photos.getWithoutGeoData'
          fix_common!(data)
        when 'flickr.photos.recentlyUpdated'
          fix_common!(data)

        # photosets
        when 'flickr.photosets.getInfo'
          data['photoset']['title'] = data['photoset']['title']['_content']
          data['photoset']['description'] = data['photoset']['description']['_content']
        when 'flickr.photosets.getList'
          data['photosets']['photoset'].map! do |set_hash|
            set_hash['count_photos'] = set_hash.delete('photos')
            set_hash['count_videos'] = set_hash.delete('videos')
            set_hash['title'] = set_hash['title']['_content']
            set_hash['description'] = set_hash['description']['_content']
            set_hash['owner'] = query['user_id'].first
            set_hash
          end
        end
      end

      def fix_extras!(hash)
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
      end

      def fix_visibility!(hash)
        hash['visibility'] = {
          'ispublic' => hash.delete('ispublic'),
          'isfriend' => hash.delete('isfriend'),
          'isfamily' => hash.delete('isfamily')
        }
      end

      def fix_common!(hash)
        hash['photos']['photo'].map! do |media_hash|
          media_hash['owner'] = {
            'id' => media_hash['owner'],
            'nsid' => media_hash.delete('owner'),
            'username' => media_hash.delete('ownername')
          }
          fix_extras!(media_hash)
          fix_visibility!(media_hash)
          media_hash
        end
      end
    end
  end
end

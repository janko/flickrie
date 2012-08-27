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
        query = CGI.parse(response.env[:url].query)
        flickr_method = query['method'].first

        case flickr_method
        when "flickr.photos.getSizes"
          response.env[:body]['sizes']['id'] = query['photo_id'].first
        when "flickr.photosets.getList"
          response.env[:body]['photosets']['photoset'].map! do |set_hash|
            set_hash['owner'] = query['user_id'].first
            set_hash
          end
        end

        response.env[:body] = cleanup_content(response.env[:body])
        action = actions[flickr_method]
        action.call(response.env[:body]) if action
      end

      def actions
        @actions ||= {
          "flickr.people.findByUsername" => lambda { |data| },
          "flickr.people.findByEmail" => lambda { |data| },
          "flickr.people.getInfo" => lambda { |data| },
          "flickr.people.getUploadStatus" => lambda { |data|
            data['user']['upload_status'] = {
              'bandwidth' => data['user'].delete('bandwidth'),
              'filesize' => data['user'].delete('filesize'),
              'sets' => data['user'].delete('sets'),
              'videosize' => data['user'].delete('videosize'),
              'videos' => data['user'].delete('videos')
            }
          },
          "flickr.people.getPhotos" => lambda { |data| fix_common!(data) },
          "flickr.people.getPhotosOf" => lambda { |data| fix_common!(data) },
          "flickr.people.getPublicPhotos" => lambda { |data| fix_common!(data) },

          "flickr.photos.getInfo" => lambda { |data|
            data['photo']['comments_count'] = data['photo'].delete('comments')
            data['photo']['dates']['uploaded'] = data['photo'].delete('dateuploaded') rescue nil
            data['photo']['tags'] = data['photo']['tags']['tag'] rescue nil
          },

          "flickr.photos.getSizes" => lambda { |data|
            data['sizes']['usage'] = {
              'canblog'     => data['sizes']['canblog'],
              'canprint'    => data['sizes']['canprint'],
              'candownload' => data['sizes']['candownload']
            }
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
          },
          "flickr.photos.search" => lambda { |data| fix_common!(data) },
          "flickr.photos.getContactsPhotos" => lambda { |data|
            data['photos']['photo'].each do |media_hash|
              media_hash['ownername'] = media_hash.delete('username')
            end
            fix_common!(data)
          },
          "flickr.photos.getContactsPublicPhotos" => lambda { |data|
            data['photos']['photo'].each do |media_hash|
              media_hash['ownername'] = media_hash.delete('username')
            end
            fix_common!(data)
          },
          "flickr.photos.getNotInSet" => lambda { |data| fix_common!(data) },
          "flickr.photos.getPerms" => lambda { |data|
            fix_visibility!(data['perms'])
            data['perms']['permissions'] = {
              'permcomment' => data['perms'].delete('permcomment'),
              'permaddmeta' => data['perms'].delete('permaddmeta')
            }
          },
          "flickr.photos.getRecent" => lambda { |data| fix_common!(data) },
          "flickr.photos.getUntagged" => lambda { |data| fix_common!(data) },
          "flickr.photos.getWithGeoData" => lambda { |data| fix_common!(data) },
          "flickr.photos.getWithoutGeoData" => lambda { |data| fix_common!(data) },
          "flickr.photos.recentlyUpdated" => lambda { |data| fix_common!(data) },

          "flickr.photos.comments.getList" => lambda { |data|
            data["comments"]["comment"].map! do |comment_hash|
              comment_hash["photo_id"] = data["comments"]["photo_id"]
              comment_hash["author"] = {
                "id"         => comment_hash["author"],
                "nsid"       => comment_hash.delete("author"),
                "username"   => comment_hash.delete("authorname"),
                "iconserver" => comment_hash.delete("iconserver"),
                "iconfarm"   => comment_hash.delete("iconfarm")
              }
              comment_hash
            end
          },
          "flickr.photos.comments.getRecentForContacts" => lambda { |data| fix_common!(data) },

          "flickr.photosets.getPhotos" => lambda { |data|
            data['photoset']['photo'].map! do |media_hash|
              media_hash['owner'] = {
                'id' => data['photoset']['owner'],
                'nsid' => data['photoset']['owner'],
                'username' => data['photoset']['ownername'],
              }
              fix_extras!(media_hash)
              media_hash
            end
          },
          "flickr.photosets.getInfo" => lambda { |data| },
          "flickr.photosets.getList" => lambda { |data|
            data['photosets']['photoset'].map! do |set_hash|
              set_hash['count_photos'] = set_hash.delete('photos')
              set_hash['count_videos'] = set_hash.delete('videos')
              set_hash['title'] = set_hash['title']['_content'] rescue nil
              set_hash['description'] = set_hash['description']['_content'] rescue nil
              set_hash
            end
          },
          "flickr.reflection.getMethods" => lambda { |data|
            data['methods']['method'].map! { |hash| hash["_content"] }
          },
          "flickr.test.login" => lambda { |data| }
        }
      end

      def cleanup_content(data)
        data.inject({}) do |hash, (key, value)|
          hash[key] =
            if value.is_a?(Hash)
              value.count == 1 ? (value["_content"] || cleanup_content(value)) : cleanup_content(value)
            else
              value
            end
          hash
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

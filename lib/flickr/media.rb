require 'flickr/media/visibility'
require 'flickr/media/note'
require 'flickr/location'
require 'date'

module Flickr
  module Media
    def id;             @info['id']           end
    def secret;         @info['secret']       end
    def server;         @info['server']       end
    def farm;           @info['farm']         end
    def title;          @info['title']        end
    def description;    @info['description']  end
    def tags;           @info['tags']         end
    def machine_tags;   @info['machine_tags'] end
    def media_status;   @info['media_status'] end
    def path_alias;     @info['pathalias']    end

    def views_count
      @info['views'].to_i if @info['views']
    end

    def comments_count
      @info['comments_count'].to_i if @info['comments_count']
    end

    def location
      Location.new(@info['location']) if @info['location']
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

    def notes
      @info['notes']['note'].map { |hash| Note.new(hash) } if @info['notes']
    end

    def get_info(info = nil)
      info ||= Flickr.client.get_media_info(id).body['photo']

      # Fixes
      info['title'] = info['title']['_content']
      info['description'] = info['description']['_content']
      info['comments_count'] = info.delete('comments')['_content']
      info['dates']['uploaded'] = info.delete('dateuploaded')
      info['machine_tags'] = info['tags']['tag'].
        select { |tag| tag['machine_tag'].to_i == 1 }.
        map { |tag| tag['_content']}.join(' ')
      info['tags'] = info['tags']['tag'].
        select { |tag| tag['machine_tag'].to_i == 0 }.
        map { |tag| tag['_content']}.join(' ')

      @info.update(info)
      self
    end

    def initialize(info = {})
      @info = info
      @info['dates'] ||= {}
      @info['usage'] ||= {}
    end

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
          info['usage'] = {}

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

      def from_sizes(info, media_id)
        new.get_sizes(info.update('id' => media_id))
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

__END__


{
  "id"=>"6923154272",
  "secret"=>"5519fab554",
  "server"=>"5279",
  "farm"=>6,
  "dateuploaded"=>"1334189525",
  "isfavorite"=>0,
  "license"=>"0",
  "safety_level"=>"0",
  "rotation"=>0,
  "owner"=>
   {"nsid"=>"67131352@N04",
    "username"=>"Janko Marohnić",
    "realname"=>"",
    "location"=>"",
    "iconserver"=>"0",
    "iconfarm"=>0},
  "title"=>{"_content"=>"David Belle - Canon commercial"},
  "description"=>{"_content"=>""},
  "visibility"=>{"ispublic"=>1, "isfriend"=>0, "isfamily"=>0},
  "dates"=>
   {"posted"=>"1334189525",
    "taken"=>"2012-04-11 17:12:05",
    "takengranularity"=>"0",
    "lastupdate"=>"1334259651"},
  "views"=>"1",
  "editability"=>{"cancomment"=>0, "canaddmeta"=>0},
  "publiceditability"=>{"cancomment"=>1, "canaddmeta"=>0},
  "usage"=>{"candownload"=>1, "canblog"=>0, "canprint"=>0, "canshare"=>0},
  "comments"=>{"_content"=>"0"},
  "notes"=>{"note"=>[]},
  "people"=>{"haspeople"=>0},
  "tags"=>
   {"tag"=>
     [{"id"=>"67099213-6923154272-471",
       "author"=>"67131352@N04",
       "raw"=>"David",
       "_content"=>"david",
       "machine_tag"=>0},
      {"id"=>"67099213-6923154272-18012",
       "author"=>"67131352@N04",
       "raw"=>"Belle",
       "_content"=>"belle",
       "machine_tag"=>0}]},
  "location"=> {...}
  "geoperms"=>{"ispublic"=>1, "iscontact"=>0, "isfriend"=>0, "isfamily"=>0},
  "urls"=>
   {"url"=>
     [{"type"=>"photopage",
       "_content"=>"http://www.flickr.com/photos/67131352@N04/6923154272/"}]},
}

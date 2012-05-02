module Flickrie
  class Set
    def id;          @info['id']          end
    def secret;      @info['secret']      end
    def server;      @info['server']      end
    def farm;        @info['farm']        end
    def title;       @info['title']       end
    def description; @info['description'] end

    def primary_media_id; @info['primary'] end
    alias primary_photo_id primary_media_id
    alias primary_video_id primary_media_id

    def views_count; @info['count_views'].to_i if @info['count_views'] end
    def comments_count; @info['count_comments'].to_i if @info['count_comments'] end
    def photos_count; @info['count_photos'].to_i if @info['count_photos'] end
    def videos_count; @info['count_videos'].to_i if @info['count_videos'] end
    def media_count; photos_count + videos_count rescue nil end

    def owner; User.new('nsid' => @info['owner']) if @info['owner'] end

    def photos(params = {}); Flickrie.photos_from_set(id, params) end
    def videos(params = {}); Flickrie.videos_from_set(id, params) end
    def media(params = {});  Flickrie.media_from_set(id, params)  end

    def can_comment?; @info['can_comment'].to_i == 1 if @info['can_comment'] end

    # TODO: Figure out what this is
    def needs_interstitial?; @info['needs_interstitial'].to_i == 1 end
    def visibility_can_see_set?; @info['visibility_can_see_set'].to_i == 1 end

    def created_at; Time.at(@info['date_create'].to_i) end
    def updated_at; Time.at(@info['date_update'].to_i) end

    def url; "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}" end

    def get_info(info = nil)
      info ||= Flickrie.client.get_set_info(id).body['photoset']
      info['title'] = info['title']['_content']
      info['description'] = info['description']['_content']
      @info.update(info)

      self
    end

    private

    def initialize(info = {})
      @info = info
    end

    def self.from_info(info)
      new.get_info(info)
    end

    def self.from_user(info, user_nsid)
      info.map do |info|
        info['count_photos'] = info.delete('photos')
        info['count_videos'] = info.delete('videos')
        info['title'] = info['title']['_content']
        info['description'] = info['description']['_content']
        info['owner'] = user_nsid

        new(info)
      end
    end
  end
end

__END__

{
  "id"=>"72157629443464020",
  "primary"=>"6913731566",
  "secret"=>"23879c079a",
  "server"=>"7130",
  "farm"=>8,
  "photos"=>"1",
  "videos"=>0,
  "title"=>{"_content"=>"Bla"},
  "description"=>{"_content"=>""},
  "needs_interstitial"=>0,
  "visibility_can_see_set"=>1,
  "count_views"=>"0",
  "count_comments"=>"0",
  "can_comment"=>0,
  "date_create"=>"1334331151",
  "date_update"=>"1334331155
}

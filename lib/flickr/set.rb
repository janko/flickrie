require 'flickr/user'

module Flickr
  class Set
    def id; @info['id'].to_i end
    def secret; @info['secret'] end
    def server; @info['server'].to_i end
    def farm; @info['farm'].to_i end
    def title; @info['title'] end
    def description; @info['description'] end

    def primary_item_id; @info['primary'].to_i end
    alias primary_photo_id primary_item_id
    alias primary_video_id primary_item_id

    def items_count; @info['photos'].to_i end
    def views_count; @info['count_views'].to_i end
    def comments_count; @info['count_comments'].to_i end
    def photos_count; @info['count_photos'].to_i end
    def videos_count; @info['count_videos'].to_i end

    def owner; User.new('nsid' => @info['owner']) end

    def can_comment?; @info['can_comment'].to_i == 1 end

    # TODO: Figure out what this is
    def needs_interstitial?; @info['needs_interstitial'].to_i == 1 end
    def visibility_can_see_set?; @info['visibility_can_see_set'].to_i == 1 end

    def created_at; Time.at(@info['date_create'].to_i) end
    def updated_at; Time.at(@info['date_update'].to_i) end

    def url; "http://www.flickr.com/photos/#{owner.nsid}/sets/#{id}" end

    private

    def initialize(info)
      @info = info

      # Fixes
      @info['title'] = @info['title']['_content']
      @info['description'] = @info['description']['_content']
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

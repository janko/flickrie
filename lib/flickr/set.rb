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
  'id' => '72157629409394888',
  'owner' => '67131352@N04',
  'primary' => '6913663366',
  'secret' => '0c9fb32336',
  'server' => '5240',
  'farm' => 6,
  'photos' => 2,
  'count_views' => '0',
  'count_comments' => '0',
  'count_photos' => '2',
  'count_videos' => 0,
  'title' => {'_content' => 'rođendan'},
  'description' => {'_content' => ''},
  'can_comment' => 0,
  'date_create' => '1333954490',
  'date_update' => '1333956652'
}

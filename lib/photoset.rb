require 'object'
require 'flickr'

module Flickr
  class Photoset < Flickr::Object
    def title
      @hash['title']['_content']
    end

    def description
      @hash['description']['_content']
    end

    def id
      @hash['id'].to_i
    end

    def owner_id
      @hash['owner']
    end

    def owner
      @owner ||= Flickr.find_user_by_id(owner_id)
    end

    def photos_count
      @hash['photos'].to_i
    end

    def comments_count
      @hash['count_comments'].to_i
    end

    def created_at
      Time.at(@hash['date_create'].to_i)
    end

    def updated_at
      Time.at(@hash['date_update'].to_i)
    end

    def flickr_hash
      @hash
    end

    private

    def initialize(hash)
      @hash = hash
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

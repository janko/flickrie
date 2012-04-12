require 'object'
require 'flickr'

module Flickr
  class Photoset < Flickr::Object
    attr_reader :id, :owner_id, :primary_photo_id, :secret,
      :url, :items_count, :photos_count, :views_count,
      :comments_count, :videos_count, :title, :description,
      :created_at, :updated_at

    def owner
      @owner ||= Flickr.find_user_by_id(@owner_id)
    end

    def primary_photo
      @primary_photo ||= Flickr.find_photo_by_id(@primary_photo_id)
    end

    def can_comment?
      @can_comment
    end

    private

    def initialize(info)
      @id = info['id']
      @owner_id = info['owner']
      @primary_photo_id = info['primary']
      @secret = info['secret']
      @url = "http://www.flickr.com/photos/#{@owner_id}/sets/#{@id}"
      @items_count = info['photos'].to_i
      @photos_count = info['count_photos'].to_i
      @views_count = info['count_views'].to_i
      @comments_count = info['count_comments'].to_i
      @videos_count = info['count_videos'].to_i
      @title = info['title']['_content']
      @description = info['description']['_content']
      @can_comment = (info['can_comment'].to_i == 1)
      @created_at = Time.at(info['date_create'])
      @updated_at = Time.at(info['date_update'])
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

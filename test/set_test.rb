# encoding: utf-8
require 'test/unit'
require 'flickr/set'
require 'flickr'
require 'flickr/client'
require 'flickr/user'
require 'flickr/photo'

class SetTest < Test::Unit::TestCase
  Flickr::Set.instance_eval do
    def public_new(*args)
      new(*args)
    end
  end

  def test_attributes
    info_hash = {
      'id' => '72157629409394888',
      'owner' => '67131352@N04',
      'primary' => '6913663366',
      'secret' => '0c9fb32336',
      'server' => '5240',
      'farm' => 6,
      'photos' => 3,
      'count_views' => '0',
      'count_comments' => '0',
      'count_photos' => '2',
      'count_videos' => 1,
      'title' => {'_content' => 'rođendan'},
      'description' => {'_content' => ''},
      'can_comment' => 1,
      'date_create' => '1333954490',
      'date_update' => '1333956652'
    }
    set = Flickr::Set.public_new(info_hash)

    assert_equal '72157629409394888', set.id
    assert_equal '67131352@N04', set.owner.nsid
    assert_equal '6913663366', set.primary_item_id
    assert_equal '0c9fb32336', set.secret
    assert_equal 6, set.farm
    assert_equal 'rođendan', set.title
    assert_equal '', set.description

    assert_equal 3, set.items_count
    assert_equal 2, set.photos_count
    assert_equal 1, set.videos_count
    assert_equal 0, set.comments_count
    assert_equal 0, set.views_count

    assert_instance_of Flickr::Photo, set.photos.first

    assert_instance_of Flickr::User, set.owner
    assert set.can_comment?
    refute set.url.empty?

    assert_instance_of Time, set.created_at
    assert_instance_of Time, set.updated_at
  end
end

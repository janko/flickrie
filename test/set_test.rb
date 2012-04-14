# encoding: utf-8
require 'test/unit'
require 'flickr/set'

class SetTest < Test::Unit::TestCase
  Flickr::Set.instance_eval do
    def public_new(*args)
      new(*args)
    end
  end

  HASH = {
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

  def test_attributes
    set = Flickr::Set.public_new(HASH)

    assert_equal 72157629409394888, set.id
    assert_equal "67131352@N04", set.owner_id
    assert_equal 2, set.photos_count
    assert_equal 0, set.comments_count
    assert_equal "rođendan", set.title
    assert_equal "", set.description
    assert_equal Time.at(1333954490), set.created_at
    assert_equal Time.at(1333956652), set.updated_at
    assert_equal HASH, set.flickr_hash

    Flickr.api_key = ENV['FLICKR_API_KEY']
    assert_equal "67131352@N04", set.owner.id
  end
end

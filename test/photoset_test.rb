# encoding: utf-8
require 'test/unit'
require 'photoset'

class PhotosetTest < Test::Unit::TestCase
  include Flickr

  def Photoset.public_new(*args)
    new(*args)
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
    photoset = Photoset.public_new(HASH)

    assert_equal 72157629409394888, photoset.id
    assert_equal "67131352@N04", photoset.owner_id
    assert_equal 2, photoset.photos_count
    assert_equal 0, photoset.comments_count
    assert_equal "rođendan", photoset.title
    assert_equal "", photoset.description
    assert_equal Time.at(1333954490), photoset.created_at
    assert_equal Time.at(1333956652), photoset.updated_at
    assert_equal HASH, photoset.flickr_hash

    Flickr.api_key = ENV['FLICKR_API_KEY']
    assert_equal "67131352@N04", photoset.owner.id
  end
end

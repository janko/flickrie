# encoding: utf-8
require 'test/unit'
require 'flickr/photo'
require 'flickr/client'
require 'flickr/user'
require 'flickr/license'

class PhotoTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_from_info
    info_hash = {}
    tests = []

    info_hash.update \
      "id" => "6923154272",
      "secret" => "5519fab554",
      "server" => "5279",
      "farm" => 6,
      "dateuploaded" => "1334189525",
      "isfavorite" => 0
    tests << ->(photo) do
      assert_equal 6923154272, photo.id
      assert_equal '5519fab554', photo.secret
      assert_equal 5279, photo.server
      assert_equal 6, photo.farm
      assert_instance_of Time, photo.uploaded_at
      assert_equal false, photo.favorite?
    end

    info_hash.update \
      "license" => "0"
    tests << ->(photo) do
      assert_instance_of Flickr::License, photo.license
      assert_equal 0, photo.license.id
      assert_instance_of String, photo.license.name
      assert_instance_of String, photo.license.url
    end

    info_hash.update \
      "safety_level" => "0",
      "rotation" => 0,
      "title" => {"_content" => "David Belle - Canon commercial"},
      "description" => {"_content" => ""}
    tests << ->(photo) do
      assert_equal 0, photo.safety_level
      assert_equal true, photo.safe?
      assert_equal 0, photo.rotation
      assert_equal "David Belle - Canon commercial", photo.title
      assert_equal "", photo.description
    end

    info_hash.update \
      "id" => "6923154272",
      "owner" => {
        "nsid" => "67131352@N04",
        "username" => "Janko Marohnić",
        "realname" => "",
        "location" => "",
        "iconserver" => "0",
        "iconfarm" => 0
      }
    tests << ->(photo) do
      assert_instance_of Flickr::User, photo.owner
      assert_equal "67131352@N04", photo.owner.nsid
      assert_equal "Janko Marohnić", photo.owner.username
      assert photo.owner.real_name.empty?
      assert photo.owner.location.empty?
      refute photo.owner.buddy_icon_url.empty?
      refute photo.url.empty?
    end

    info_hash.update \
      "visibility"        => {"ispublic" => 1, "isfriend" => 0, "isfamily" => 0},
      "editability"       => {"cancomment" => 0, "canaddmeta" => 0},
      "publiceditability" => {"cancomment" => 1, "canaddmeta" => 0},
      "usage"             => {"candownload" => 1, "canblog" => 0, "canprint" => 0, "canshare" => 0},
      "people"            => {"haspeople" => 1}
    tests << ->(photo) do
      assert_instance_of Flickr::Media::Visibility, photo.visibility
      assert_equal true, photo.visibility.public?
      assert_equal false, photo.can_comment?
      assert_equal false, photo.can_add_meta?
      assert_equal true, photo.can_everyone_comment?
      assert_equal false, photo.can_everyone_add_meta?
      assert_equal true, photo.can_download?
      assert_equal false, photo.can_blog?
      assert_equal false, photo.can_print?
      assert_equal false, photo.can_share?
      assert_equal true, photo.has_people?
    end

    info_hash.update \
      "dates" => {
        "posted" => "1334189525",
        "taken" => "2012-04-11 17:12:05",
        "takengranularity" => "0",
        "lastupdate" => "1334259651"
      }
    tests << ->(photo) do
      assert_instance_of Time, photo.posted_at
      assert_instance_of Time, photo.taken_at
      assert_instance_of Time, photo.updated_at
      assert_equal 0, photo.taken_at_granularity
    end

    info_hash.update \
      "views" => "1",
      "comments" => {"_content" => "3"}
    tests << ->(photo) do
      assert_equal 1, photo.views_count
      assert_equal 3, photo.comments_count
    end

    info_hash.update \
      "notes" => {"note" =>
        [
          {
            "id" => "72157629434940218",
            "author" => "67131352@N04",
            "authorname" => "Janko Marohnić",
            "x" => "16",
            "y" => "16",
            "w" => "31",
            "h" => "31",
            "_content" => "Headashgfsdg"
          }
        ]
      }
    tests << ->(photo) do
      note = photo.notes.first
      assert_instance_of Flickr::Media::Note, note
      assert_equal 72157629434940218, note.id
      assert_instance_of Flickr::User, note.author
      assert_equal '67131352@N04', note.author.nsid
      assert_equal "Janko Marohnić", note.author.username
      assert_equal [16, 16], note.coordinates.bottom_left
      assert_equal [31, 31], note.coordinates.top_right
      assert_equal "Headashgfsdg", note.content
    end

    info_hash.update \
      "tags" => {"tag" =>
        [
          {
            "id" => "67099213-6923154272-471",
            "author" => "67131352@N04",
            "raw" => "David",
            "_content" => "david",
            "machine_tag" => 0
          },
          {
            "id" => "67099213-6923154272-18012",
            "author" => "67131352@N04",
            "raw" => "Belle",
            "_content" => "belle",
            "machine_tag" => 0
          }
        ]
      }
    tests << ->(photo) do
      assert_equal "david belle", photo.tags
      assert_equal "", photo.machine_tags
    end

    info_hash.update \
      "location" => {
        "latitude" => 37.792608,
        "longitude" => -122.402672,
        "accuracy" => "14",
        "context" => "0",
        "neighbourhood" => {
          "_content" => "Financial District",
          "place_id" => "GddgqTpTUb8LgT93hw",
          "woeid" => "23512022"
        },
        "locality" => {
          "_content" => "San Francisco",
          "place_id" => "7.MJR8tTVrIO1EgB",
          "woeid" => "2487956"
        },
        "county" => {
          "_content" => "San Francisco",
          "place_id" => ".7sOmlRQUL9nK.kMzA",
          "woeid" => "12587707"
        },
        "region" => {
          "_content" => "California",
          "place_id" => "NsbUWfBTUb4mbyVu",
          "woeid" => "2347563"
        },
        "country" => {
          "_content" => "United States",
          "place_id" => "nz.gsghTUb4c2WAecA",
          "woeid" => "23424977"
        },
        "place_id" => "GddgqTpTUb8LgT93hw",
        "woeid" => "23512022"
      },
      "geoperms" => {"ispublic" => 1, "iscontact" => 0, "isfriend" => 0, "isfamily" => 0}
    tests << ->(photo) do
      location = photo.location
      assert_instance_of Flickr::Location, location
      assert_equal 37.792608, location.latitude
      assert_equal -122.402672, location.longitude
      assert_equal "14", location.accuracy
      assert_equal "0", location.context

      assert_equal "Financial District", location.neighbourhood.name
      assert_equal "GddgqTpTUb8LgT93hw", location.neighbourhood.id
      assert_equal "23512022",           location.neighbourhood.woeid
      assert_equal "San Francisco",      location.locality.name
      assert_equal "7.MJR8tTVrIO1EgB",   location.locality.id
      assert_equal "2487956",            location.locality.woeid
      assert_equal "San Francisco",      location.county.name
      assert_equal ".7sOmlRQUL9nK.kMzA", location.county.id
      assert_equal "12587707",           location.county.woeid
      assert_equal "California",         location.region.name
      assert_equal "NsbUWfBTUb4mbyVu",   location.region.id
      assert_equal "2347563",            location.region.woeid
      assert_equal "United States",      location.country.name
      assert_equal "nz.gsghTUb4c2WAecA", location.country.id
      assert_equal "23424977",           location.country.woeid

      assert_equal "GddgqTpTUb8LgT93hw", location.id
      assert_equal "23512022", location.woeid

      assert_instance_of Flickr::Media::Visibility, photo.geo_permissions
      assert_equal true, photo.geo_permissions.public?
    end

    photo = Flickr::Photo.from_info(info_hash)
    tests.each { |test| test.call(photo) }
  end

  def test_from_set
    set_hash = {
      "id" => "72157629443464020",
      "primary" => "6913731566",
      "owner" => "67131352@N04",
      "ownername" => "Janko Marohnić",
      "photo" => [
        {"id" => "6913731566",
         "secret" => "23879c079a",
         "server" => "7130",
         "farm" => 8,
         "title" => "6913664138_61ffb9c0d7_b",
         "isprimary" => "1",
         "license" => "0",
         "dateupload" => "1333956611",
         "datetaken" => "2012-04-09 00:30:11",
         "datetakengranularity" => "0",
         "ownername" => "Janko Marohnić",
         "iconserver" => "0",
         "iconfarm" => 0,
         "lastupdate" => "1334347067",
         "latitude" => 0,
         "longitude" => 0,
         "accuracy" => 0,
         "context" => 0,
         "tags" => "zakon",
         "machine_tags" => "",
         "views" => "1",
         "media" => "photo",
         "media_status" => "ready",
         "pathalias" => nil,
         "url_sq" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_s.jpg",
         "height_sq" => 75,
         "width_sq" => 75,
         "url_q" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_q.jpg",
         "height_q" => "150",
         "width_q" => "150",
         "url_t" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_t.jpg",
         "height_t" => "100",
         "width_t" => "75",
         "url_s" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_m.jpg",
         "height_s" => "240",
         "width_s" => "180",
         "url_n" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_n.jpg",
         "height_n" => "320",
         "width_n" => 240,
         "url_m" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a.jpg",
         "height_m" => "500",
         "width_m" => "375",
         "url_z" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_z.jpg",
         "height_z" => "640",
         "width_z" => "480",
         "url_c" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_c.jpg",
         "height_c" => "800",
         "width_c" => 600,
         "url_l" => "http://farm8.staticflickr.com/7130/6913731566_23879c079a_b.jpg",
         "height_l" => "1024",
         "width_l" => "768"}
      ]
    }
    photo = Flickr::Photo.from_set(set_hash)
    assert_equal "Large 1024", photo.size
    assert photo.primary?
    assert_equal Flickr::Photo::SIZES.keys[0..-2], photo.available_sizes
    photo.thumbnail!
    assert_equal "Large 1024", photo.largest!.size
    assert_equal [768, 1024], [photo.width, photo.height]
    assert_instance_of Flickr::User, photo.owner
    assert_equal 6913731566, photo.id
    assert_equal "23879c079a", photo.secret
    assert_equal 7130, photo.server
    assert_equal 8, photo.farm
    assert_equal "6913664138_61ffb9c0d7_b", photo.title
    assert_equal true, photo.primary?

    # Extras
    assert_instance_of Flickr::License, photo.license
    assert_instance_of Time, photo.uploaded_at
    assert_instance_of Time, photo.taken_at
    assert_instance_of Time, photo.updated_at
    assert_equal 0, photo.taken_at_granularity
    refute photo.owner.buddy_icon_url.empty?
    assert_instance_of Flickr::Location, photo.location
    assert_equal "zakon", photo.tags
    assert_instance_of String, photo.machine_tags
    assert_equal 1, photo.views_count
    assert_equal "ready", photo.media_status
    assert photo.path_alias.nil?

    photo.get_info
    test_from_info
  end
end

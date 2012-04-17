# encoding: utf-8
require 'test/unit'
require 'flickr/video'
require 'flickr/client'
require 'flickr/user'
require 'flickr/license'

class VideoTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_from_info
    info_hash = {
      "id" => "6923154272",
      "secret" => "5519fab554",
      "server" => "5279",
      "farm" => 6,
      "dateuploaded" => "1334189525",
      "isfavorite" => 0,
      "license" => "0",
      "safety_level" => "0",
      "rotation" => 0,
      "title" => {"_content" => "David Belle - Canon commercial"},
      "description" => {"_content" => ""},
      "owner" => {
        "nsid" => "67131352@N04",
        "username" => "Janko Marohnić",
        "realname" => "",
        "location" => "",
        "iconserver" => "0",
        "iconfarm" => 0
      },
      "visibility" => {"ispublic" => 1, "isfriend" => 0, "isfamily" => 0},
      "editability" => {"cancomment" => 0, "canaddmeta" => 0},
      "publiceditability" => {"cancomment" => 1, "canaddmeta" => 0},
      "usage" => {"candownload" => 1, "canblog" => 0, "canprint" => 0, "canshare" => 0},
      "people" => {"haspeople" => 1},
      "dates" => {
        "posted" => "1334189525",
        "taken" => "2012-04-11 17:12:05",
        "takengranularity" => "0",
        "lastupdate" => "1334259651"
      },
      "views" => "1",
      "comments" => {"_content" => "3"},
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
      },
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
      },
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
      "geoperms" => {"ispublic" => 1, "iscontact" => 0, "isfriend" => 0, "isfamily" => 0},
      "media" => "video",
      "video" => {
        "ready" => 1,
        "failed" => 0,
        "pending" => 0,
        "duration" => "34",
        "width" => "480",
        "height" => "360"}
    }

    video = Flickr::Video.from_info(info_hash)

    assert_equal '6923154272', video.id
    assert_equal '5519fab554', video.secret
    assert_equal '5279', video.server
    assert_equal 6, video.farm
    assert_instance_of Time, video.uploaded_at
    assert_equal false, video.favorite?

    assert_instance_of Flickr::License, video.license
    assert_equal 0, video.license.id
    assert_instance_of String, video.license.name
    assert_instance_of String, video.license.url

    assert_equal 0, video.safety_level
    assert_equal true, video.safe?
    assert_equal "David Belle - Canon commercial", video.title
    assert_equal "", video.description

    assert_instance_of Flickr::User, video.owner
    assert_equal "67131352@N04", video.owner.nsid
    assert_equal "Janko Marohnić", video.owner.username
    assert video.owner.real_name.empty?
    assert video.owner.location.empty?
    refute video.owner.buddy_icon_url.empty?
    refute video.url.empty?

    assert_instance_of Flickr::Media::Visibility, video.visibility
    assert_equal true, video.visibility.public?
    assert_equal false, video.can_comment?
    assert_equal false, video.can_add_meta?
    assert_equal true, video.can_everyone_comment?
    assert_equal false, video.can_everyone_add_meta?
    assert_equal true, video.can_download?
    assert_equal false, video.can_blog?
    assert_equal false, video.can_print?
    assert_equal false, video.can_share?
    assert_equal true, video.has_people?

    assert_instance_of Time, video.posted_at
    assert_instance_of Time, video.taken_at
    assert_instance_of Time, video.updated_at
    assert_equal 0, video.taken_at_granularity

    assert_equal 1, video.views_count
    assert_equal 3, video.comments_count

    note = video.notes.first
    assert_instance_of Flickr::Media::Note, note
    assert_equal 72157629434940218, note.id
    assert_instance_of Flickr::User, note.author
    assert_equal '67131352@N04', note.author.nsid
    assert_equal "Janko Marohnić", note.author.username
    assert_equal [16, 16], note.coordinates.bottom_left
    assert_equal [31, 31], note.coordinates.top_right
    assert_equal "Headashgfsdg", note.content

    assert_equal "david belle", video.tags
    assert_equal "", video.machine_tags

    location = video.location
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

    assert_instance_of Flickr::Media::Visibility, video.geo_permissions
    assert_equal true, video.geo_permissions.public?

    assert video.ready?
    refute video.failed?
    refute video.pending?
    assert_equal 34, video.duration
    assert_equal 480, video.width
    assert_equal 360, video.height

    video.get_sizes
    refute video.source_url.empty?
    refute video.download_url.empty?
    refute video.mobile_download_url.empty?
  end

  def test_from_set
    set_hash = {
      "id" => "6913731566",
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
      "media" => "video",
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
      "width_l" => "768"
    }
    video = Flickr::Video.from_set(set_hash)
    assert_instance_of Flickr::License, video.license
    assert_instance_of Time, video.uploaded_at
    assert_instance_of Time, video.taken_at
    assert_instance_of Time, video.updated_at
    assert_equal 0, video.taken_at_granularity
    refute video.owner.buddy_icon_url.empty?
    assert_instance_of Flickr::Location, video.location
    assert_equal "zakon", video.tags
    assert_instance_of String, video.machine_tags
    assert_equal 1, video.views_count
    assert_equal "ready", video.media_status
    assert video.path_alias.nil?

    video.get_info
    test_from_info
  end

  def test_methods_returning_nil
    video = Flickr::Video.new

    assert_nil video.id
    assert_nil video.secret
    assert_nil video.server
    assert_nil video.farm
    assert_nil video.title
    assert_nil video.description
    assert_nil video.tags
    assert_nil video.machine_tags
    assert_nil video.media_status
    assert_nil video.path_alias
    assert_nil video.views_count
    assert_nil video.comments_count
    assert_nil video.location
    assert_nil video.geo_permissions
    assert_nil video.license
    assert_nil video.posted_at
    assert_nil video.uploaded_at
    assert_nil video.updated_at
    assert_nil video.taken_at
    assert_nil video.taken_at_granularity
    assert_nil video.owner
    assert_nil video.safety_level
    assert_nil video.safe?
    assert_nil video.moderate?
    assert_nil video.restricted?
    assert_nil video.url
    assert_nil video.visibility
    assert_nil video.primary?
    assert_nil video.favorite?
    assert_nil video.can_comment?
    assert_nil video.can_add_meta?
    assert_nil video.can_everyone_comment?
    assert_nil video.can_everyone_add_meta?
    assert_nil video.can_download?
    assert_nil video.can_blog?
    assert_nil video.can_print?
    assert_nil video.can_share?
    assert_nil video.has_people?
    assert_nil video.notes

    assert_nil video.ready?
    assert_nil video.failed?
    assert_nil video.pending?
    assert_nil video.duration
    assert_nil video.width
    assert_nil video.height
    assert_nil video.source_url
    assert_nil video.download_url
    assert_nil video.mobile_download_url
  end
end

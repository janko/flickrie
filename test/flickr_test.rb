# encoding: utf-8
require 'test/unit'
require 'flickr'

class FlickrTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV["FLICKR_API_KEY"]
  end

  def test_items_from_set
    set_id = 72157629409394888

    photo = Flickr.photos_from_set(set_id).first
    assert_instance_of Flickr::Photo, photo
    assert photo.title.is_a?(String) && !photo.title.empty?

    video = Flickr.videos_from_set(set_id).first
    assert_instance_of Flickr::Video, video
    assert video.title.is_a?(String) && !video.title.empty?

    assert_instance_of Flickr::Photo, Flickr.items_from_set(set_id).first
    assert_instance_of Flickr::Video, Flickr.items_from_set(set_id).last
  end

  def test_finding_items_by_id
    photo_id = 6913731566
    video_id = 6923154272

    photo = Flickr.find_photo_by_id(photo_id)
    assert_instance_of Flickr::Photo, photo
    assert photo.title.is_a?(String) && !photo.title.empty?

    video = Flickr.find_video_by_id(video_id)
    assert_instance_of Flickr::Video, video
    assert video.title.is_a?(String) && !video.title.empty?

    assert_instance_of Flickr::Video, Flickr.find_item_by_id(video_id)
  end

  def test_sets
    set_id = 72157629409394888
    sets = Flickr.sets_from_user('67131352@N04')
    assert sets.all? { |set| set.is_a?(Flickr::Set) }
    assert sets.first.title.is_a?(String) && !sets.first.title.empty?

    set = Flickr.find_set_by_id(set_id)
    assert_instance_of Flickr::Set, set
    assert set.title.is_a?(String) && !set.title.empty?
  end

  def test_licenses
    licenses = Flickr.get_licenses
    assert licenses.all? { |license| license.is_a?(Flickr::License) }
    assert licenses.first.name.is_a?(String) && !licenses.first.name.empty?
  end

  def test_user
    assert_equal '67131352@N04', Flickr.get_user_nsid(:username => 'Janko Marohnić')
    assert_equal '67131352@N04', Flickr.get_user_nsid(:email => 'janko.marohnic@gmail.com')
    assert_instance_of Flickr::User, Flickr.find_user_by_nsid('67131352@N04')
  end
end

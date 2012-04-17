# encoding: utf-8
require 'test/unit'
require 'flickr'

class FlickrTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV["FLICKR_API_KEY"]
    @set_id = 72157629409394888
    @photo_id = 6913731566
    @video_id = 6923154272
    @user_nsid = "67131352@N04"
  end

  def test_items_from_set
    photo = Flickr.photos_from_set(@set_id).first
    assert_instance_of Flickr::Photo, photo
    assert photo.title.is_a?(String) && !photo.title.empty?

    video = Flickr.videos_from_set(@set_id).first
    assert_instance_of Flickr::Video, video
    assert video.title.is_a?(String) && !video.title.empty?

    assert Flickr.items_from_set(@set_id).any? { |item| item.is_a?(Flickr::Photo) }
    assert Flickr.items_from_set(@set_id).any? { |item| item.is_a?(Flickr::Video) }
  end

  def test_getting_info
    photo = Flickr.get_photo_info(@photo_id)
    assert_instance_of Flickr::Photo, photo
    assert photo.title.is_a?(String) && !photo.title.empty?

    video = Flickr.get_video_info(@video_id)
    assert_instance_of Flickr::Video, video
    assert video.title.is_a?(String) && !video.title.empty?

    item = Flickr.get_item_info(@video_id)
    assert_instance_of Flickr::Video, item
  end

  def test_getting_sizes
    photo = Flickr.get_photo_sizes(@photo_id)
    refute photo.square75.source_url.empty?

    video = Flickr.get_video_sizes(@video_id)
    refute video.download_url.empty?
  end

  def test_items_from_user
    item = Flickr.public_items_from_user(@user_nsid).first
    assert item.title.is_a?(String) && !item.title.empty?

    photo = Flickr.public_photos_from_user(@user_nsid).first
    assert_instance_of Flickr::Photo, photo
    assert photo.title.is_a?(String) && !photo.title.empty?

    video = Flickr.public_videos_from_user(@user_nsid).first
    assert_instance_of Flickr::Video, video
    assert video.title.is_a?(String) && !video.title.empty?
  end

  def test_sets
    sets = Flickr.sets_from_user(@user_nsid)
    assert sets.all? { |set| set.is_a?(Flickr::Set) }
    assert sets.first.title.is_a?(String) && !sets.first.title.empty?

    set = Flickr.get_set_info(@set_id)
    assert_instance_of Flickr::Set, set
    assert set.title.is_a?(String) && !set.title.empty?
  end

  def test_licenses
    licenses = Flickr.get_licenses
    assert licenses.all? { |license| license.is_a?(Flickr::License) }
    assert licenses.first.name.is_a?(String) && !licenses.first.name.empty?
  end

  def test_user
    assert_equal @user_nsid, Flickr.find_user_by_username('Janko Marohnić').nsid
    assert_equal @user_nsid, Flickr.find_user_by_email('janko.marohnic@gmail.com').nsid
    assert_equal @user_nsid, Flickr.get_user_info(@user_nsid).nsid
  end
end

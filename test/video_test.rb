# encoding: utf-8
require 'test'

Flickrie::Video.instance_eval do
  def public_new(*args)
    new(*args)
  end
end

class VideoTest < Test::Unit::TestCase
  def setup
    @video_id = 7093038981
    @set_id = 72157629851991663
    @user_nsid = '67131352@N04'

    # license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o
    @all_extras = %w[license date_upload date_taken owner_name
      icon_server original_format last_update geo tags machine_tags
      o_dims views media path_alias
      url_sq url_q url_t url_s url_n url_m url_z url_c url_l url_o]
  end

  def test_get_video_info
    video = Flickrie.get_video_info(@video_id)

    assert_equal true, video.ready?
    assert_equal false, video.failed?
    assert_equal false, video.pending?

    assert_equal 16, video.duration
    assert_equal 352, video.width
    assert_equal 288, video.height

    assert_nil video.source_url
    assert_nil video.download_url
    assert_nil video.mobile_download_url
  end

  def test_get_video_sizes
    get_sizes_assertions(Flickrie.get_video_sizes(@video_id))
    get_sizes_assertions(Flickrie::Video.public_new('id' => @video_id.to_s).get_sizes)
  end

  def get_sizes_assertions(video)
    assert_equal true, video.can_download?
    assert_equal true, video.can_blog?
    assert_equal true, video.can_print?

    refute video.source_url.empty?
    refute video.download_url.empty?
    refute video.mobile_download_url.empty?
  end

  def test_methods_returning_nil
    video = Flickrie::Video.new

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

  def test_video_upload
    video_path = File.join(File.expand_path(File.dirname(__FILE__)), 'video.mov')
    video_id = Flickrie.upload(video_path)
    assert_nothing_raised(Flickrie::Error) { Flickrie.get_video_info(video_id) }
    Flickrie.delete_video(video_id)
  end

  def test_get_video_exif
    [
      Flickrie.get_video_exif(@video_id),
      Flickrie::Video.public_new('id' => @video_id).get_exif
    ].
      each do |video|
        assert_nil video.camera
        assert_nil video.exif
      end
  end


  def test_other_api_calls
    # add_video_tags, remove_video_tag,
    # search_videos, videos_from_contacts,
    # public_videos_from_user, videos_from_set

    assert_nothing_raised do
      Flickrie.add_video_tags(@video_id, "janko")
      video = Flickrie.get_video_info(@video_id)
      tag = video.tags.find { |tag| tag.content == "janko" }
      Flickrie.remove_video_tag(tag.id)
      Flickrie.videos_from_contacts(:include_self => 1)
      Flickrie.public_videos_from_user_contacts(@user_nsid, :include_self => 1)
      Flickrie.public_videos_from_user(@user_nsid)
      Flickrie.videos_from_set(@set_id)
      Flickrie.get_video_context(@video_id)
      Flickrie.search_videos(:user_id => @user_nsid)
    end
  end
end

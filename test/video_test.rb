# encoding: utf-8
require 'test/unit'
require 'flickrie'

class VideoTest < Test::Unit::TestCase
  def setup
    Flickrie.api_key = ENV['FLICKR_API_KEY']
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
    video = Flickrie.get_video_sizes(@video_id)

    assert_equal true, video.can_download?
    assert_equal false, video.can_blog?
    assert_equal false, video.can_print?

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
end

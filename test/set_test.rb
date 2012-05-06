# encoding: utf-8
require 'test'

Flickrie::Set.instance_eval do
  def public_new(*args)
    new(*args)
  end
end

class SetTest < Test::Unit::TestCase
  def setup
    @set_id = 72157629851991663
    @user_nsid = '67131352@N04'
  end

  def test_get_set_info
    VCR.use_cassette 'set/get_info' do
      [Flickrie.get_set_info(@set_id),
       Flickrie::Set.public_new('id' => @set_id.to_s).get_info].
        each do |set|
          assert_equal @set_id, set.id.to_i
          assert_equal @user_nsid, set.owner.nsid
          assert_equal '6946979188', set.primary_media_id
          assert_equal '25bb44852b', set.secret
          assert_equal '7049', set.server
          assert_equal 8, set.farm
          assert_equal 'Speleologija', set.title
          assert_equal 'Slike sa škole speleologije Velebit.', set.description

          assert_equal 98, set.media_count
          assert_equal 97, set.photos_count
          assert_equal 1, set.videos_count
          assert_equal 0, set.comments_count
          assert_equal 0, set.views_count

          assert set.photos.all? { |photo| photo.is_a?(Flickrie::Photo) }
          assert set.videos.all? { |video| video.is_a?(Flickrie::Video) }
          assert set.media.find { |media| media.is_a?(Flickrie::Photo) }
          assert set.media.find { |media| media.is_a?(Flickrie::Video) }

          assert_equal true, set.can_comment?

          assert_instance_of Time, set.created_at
          assert_instance_of Time, set.updated_at

          refute set.url.empty?
        end
    end
  end

  def test_sets_from_user
    VCR.use_cassette 'set/from_user' do
      set = Flickrie.sets_from_user(@user_nsid).
        find { |set| set.id.to_i == @set_id }

      assert_equal @set_id, set.id.to_i
      assert_equal @user_nsid, set.owner.nsid
      assert_equal '6946979188', set.primary_media_id
      assert_equal '25bb44852b', set.secret
      assert_equal '7049', set.server
      assert_equal 8, set.farm
      assert_equal 'Speleologija', set.title
      assert_equal 'Slike sa škole speleologije Velebit.', set.description

      assert_equal 98, set.media_count
      assert_equal 97, set.photos_count
      assert_equal 1, set.videos_count
      assert_equal 0, set.comments_count
      assert_equal 0, set.views_count

      assert set.photos.all? { |photo| photo.is_a?(Flickrie::Photo) }
      assert set.videos.all? { |video| video.is_a?(Flickrie::Video) }
      assert set.media.find { |media| media.is_a?(Flickrie::Photo) }
      assert set.media.find { |media| media.is_a?(Flickrie::Video) }

      assert_equal true, set.can_comment?
      assert_equal false, set.needs_interstitial?
      assert_equal true, set.visibility_can_see_set?

      assert_instance_of Time, set.created_at
      assert_instance_of Time, set.updated_at

      refute set.url.empty?
    end
  end
end

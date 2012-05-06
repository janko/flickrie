# encoding: utf-8
require 'test_helper'

Flickrie::Photo.instance_eval do
  def public_new(*args)
    new(*args)
  end
end

class MediaTest < Test::Unit::TestCase
  def setup
    @media_id = 6946979188
    @set_id = 72157629851991663
    @user_nsid = '67131352@N04'

    # license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o
    @all_extras = %w[license date_upload date_taken owner_name
      icon_server original_format last_update geo tags machine_tags
      o_dims views media path_alias
      url_sq url_q url_t url_s url_n url_m url_z url_c url_l url_o]
  end

  def test_get_media_info
    VCR.use_cassette 'media/get_info' do
      [Flickrie.get_media_info(@media_id),
       Flickrie::Photo.public_new('id' => @media_id.to_s).get_info].
        each do |media|
          assert_equal '6946979188', media.id
          assert_equal '25bb44852b', media.secret
          assert_equal '7049', media.server
          assert_equal 8, media.farm
          assert_equal 'IMG_0796', media.title

          assert_equal 'luka', media.tags.join(' ')
          assert_equal @user_nsid, media.tags.first.author.nsid
          assert_equal 'luka', media.tags.first.raw
          assert_equal false, media.tags.first.machine_tag?

          assert_equal 2, media.views_count
          assert_equal 1, media.comments_count
          assert_equal '0', media.license.id
          assert_equal 0, media.safety_level
          assert_equal 90, media.rotation
          assert_equal 'Test', media.description
          assert_not_nil media.url

          # Time
          assert_instance_of Time, media.uploaded_at
          assert_instance_of Time, media.updated_at
          assert_instance_of Time, media.taken_at
          assert_equal 0, media.taken_at_granularity
          assert_instance_of Time, media.posted_at

          # Owner
          assert_equal '67131352@N04', media.owner.nsid
          assert_equal 'Janko Marohnić', media.owner.username
          assert_equal 'Janko Marohnić', media.owner.real_name
          assert_equal 'Zagreb, Croatia', media.owner.location
          assert_equal '5464', media.owner.icon_server
          assert_equal 6, media.owner.icon_farm
          refute media.owner.buddy_icon_url.empty?

          # Predicates
          assert_equal true, media.visibility.public?
          assert_equal false, media.visibility.friends?
          assert_equal false, media.visibility.family?
          assert_equal nil, media.visibility.contacts?

          assert_equal true, media.can_comment?
          assert_equal true, media.can_add_meta?
          assert_equal true, media.can_everyone_comment?
          assert_equal false, media.can_everyone_add_meta?

          assert_equal true, media.can_download?
          assert_equal true, media.can_blog?
          assert_equal true, media.can_print?
          assert_equal false, media.can_share?

          assert_equal false, media.has_people?

          assert_equal true, media.safe?
          assert_equal false, media.moderate?
          assert_equal false, media.restricted?

          assert_equal false, media.favorite?

          assert_equal true, media.geo_permissions.public?
          assert_equal false, media.geo_permissions.contacts?
          assert_equal false, media.geo_permissions.friends?
          assert_equal false, media.geo_permissions.family?

          # Notes
          note = media.notes.first
          assert_equal '72157629487842968', note.id
          assert_equal '67131352@N04', note.author.nsid
          assert_equal 'Janko Marohnić', note.author.username
          assert_equal [316, 0], note.coordinates
          assert_equal [59, 50], [note.width, note.height]
          assert_equal 'Test', note.content

          # Location
          location = media.location

          assert_equal 45.807258, location.latitude
          assert_equal 15.967599, location.longitude
          assert_equal '11', location.accuracy
          assert_equal '0', location.context

          assert_equal nil, location.neighbourhood
          assert_equal 'Zagreb', location.locality.name
          assert_equal '00j4IylZV7scWik', location.locality.place_id
          assert_equal '851128', location.locality.woeid
          assert_equal 'Zagreb', location.county.name
          assert_equal '306dHrhQV7o6jm.ZUQ', location.county.place_id
          assert_equal '15022257', location.county.woeid
          assert_equal 'Grad Zagreb', location.region.name
          assert_equal 'Js1DU.pTUrpBCIKhVw', location.region.place_id
          assert_equal '20070170', location.region.woeid
          assert_equal 'Croatia', location.country.name
          assert_equal 'FunRCI5TUb6a6soTyw', location.country.place_id
          assert_equal '23424843', location.country.woeid

          assert_equal '00j4IylZV7scWik', location.place_id
          assert_equal '851128', location.woeid
        end
    end
  end

  def test_media_from_set
    VCR.use_cassette 'media/from_set' do
      media = Flickrie.media_from_set(@set_id, :extras => @all_extras).
        find { |media| media.id.to_i == @media_id }

      assert_equal '6946979188', media.id
      assert_equal '25bb44852b', media.secret
      assert_equal '7049', media.server
      assert_equal 8, media.farm
      assert_equal 'IMG_0796', media.title
      assert_equal 'luka', media.tags.join(' ')
      assert_equal '', media.machine_tags.join(' ')
      assert_equal 2, media.views_count
      assert_equal '0', media.license.id
      assert_equal true, media.primary?
      assert_not_nil media.url
      assert_equal 'ready', media.media_status

      # Time
      assert_instance_of Time, media.uploaded_at
      assert_instance_of Time, media.updated_at
      assert_instance_of Time, media.taken_at
      assert_equal 0, media.taken_at_granularity

      # Location
      assert_equal 45.807258, media.location.latitude
      assert_equal 15.967599, media.location.longitude
      assert_equal '11', media.location.accuracy
      assert_equal '0', media.location.context.to_s
      assert_equal '00j4IylZV7scWik', media.location.place_id
      assert_equal '851128', media.location.woeid
      assert_equal true, media.geo_permissions.public?
      assert_equal false, media.geo_permissions.contacts?
      assert_equal false, media.geo_permissions.friends?
      assert_equal false, media.geo_permissions.family?

      # Owner
      assert_equal '67131352@N04', media.owner.nsid
      assert_equal 'Janko Marohnić', media.owner.username
      assert_equal '5464', media.owner.icon_server
      assert_equal 6, media.owner.icon_farm
      refute media.owner.buddy_icon_url.empty?
    end
  end

  def test_public_media_from_user
    VCR.use_cassette 'media/from_user' do
      media = Flickrie.public_media_from_user(@user_nsid, :extras => @all_extras).
        find { |media| media.id.to_i == @media_id }

      assert_equal '6946979188', media.id
      assert_equal '25bb44852b', media.secret
      assert_equal '7049', media.server
      assert_equal 8, media.farm
      assert_equal 'IMG_0796', media.title
      assert_equal 'luka', media.tags.join(' ')
      assert_equal '', media.machine_tags.join(' ')
      assert_equal 2, media.views_count
      assert_equal '0', media.license.id
      assert_not_nil media.url
      assert_equal 'ready', media.media_status

      # Time
      assert_instance_of Time, media.uploaded_at
      assert_instance_of Time, media.updated_at
      assert_instance_of Time, media.taken_at
      assert_equal 0, media.taken_at_granularity

      # Location
      assert_equal 45.807258, media.location.latitude
      assert_equal 15.967599, media.location.longitude
      assert_equal '11', media.location.accuracy
      assert_equal '0', media.location.context.to_s
      assert_equal '00j4IylZV7scWik', media.location.place_id
      assert_equal '851128', media.location.woeid
      assert_equal true, media.geo_permissions.public?
      assert_equal false, media.geo_permissions.contacts?
      assert_equal false, media.geo_permissions.friends?
      assert_equal false, media.geo_permissions.family?

      # Owner
      assert_equal '67131352@N04', media.owner.nsid
      assert_equal 'Janko Marohnić', media.owner.username
      assert_equal '5464', media.owner.icon_server
      assert_equal 6, media.owner.icon_farm
      refute media.owner.buddy_icon_url.empty?

      # Visibility (This is the difference from Flickrie.media_from_set)
      assert_equal true, media.visibility.public?
      assert_equal false, media.visibility.friends?
      assert_equal false, media.visibility.family?
      assert_equal nil, media.visibility.contacts?
    end
  end

  def test_search_media
    VCR.use_cassette 'media/search' do
      media = Flickrie.search_media(:user_id => @user_nsid, :extras => @all_extras).
        find { |media| media.id.to_i == @media_id }

      assert_equal '6946979188', media.id
      assert_equal '25bb44852b', media.secret
      assert_equal '7049', media.server
      assert_equal 8, media.farm
      assert_equal 'IMG_0796', media.title
      assert_equal 'luka', media.tags.join(' ')
      assert_equal '', media.machine_tags.join(' ')
      assert_equal 2, media.views_count
      assert_equal '0', media.license.id
      assert_not_nil media.url
      assert_equal 'ready', media.media_status

      # Time
      assert_instance_of Time, media.uploaded_at
      assert_instance_of Time, media.updated_at
      assert_instance_of Time, media.taken_at
      assert_equal 0, media.taken_at_granularity

      # Location
      assert_equal 45.807258, media.location.latitude
      assert_equal 15.967599, media.location.longitude
      assert_equal '11', media.location.accuracy
      assert_equal '0', media.location.context.to_s
      assert_equal '00j4IylZV7scWik', media.location.place_id
      assert_equal '851128', media.location.woeid
      assert_equal true, media.geo_permissions.public?
      assert_equal false, media.geo_permissions.contacts?
      assert_equal false, media.geo_permissions.friends?
      assert_equal false, media.geo_permissions.family?

      # Owner
      assert_equal '67131352@N04', media.owner.nsid
      assert_equal 'Janko Marohnić', media.owner.username
      assert_equal '5464', media.owner.icon_server
      assert_equal 6, media.owner.icon_farm
      refute media.owner.buddy_icon_url.empty?

      # Visibility (This is the difference from Flickrie.media_from_set)
      assert_equal true, media.visibility.public?
      assert_equal false, media.visibility.friends?
      assert_equal false, media.visibility.family?
      assert_equal nil, media.visibility.contacts?
    end
  end

  def test_tags
    VCR.use_cassette 'media/add_tags' do
      media = Flickrie.get_media_info(@media_id)
      tags_before_change = media.tags.join(' ')
      Flickrie.add_media_tags(@media_id, "janko")
      media.get_info
      assert_equal [tags_before_change, "janko"].join(' '),
        media.tags.join(' ')
      tag_id = media.tags.find { |tag| tag.content == "janko" }.id
      Flickrie.remove_media_tag(tag_id)
    end
  end

  def test_remove_media_tag
    VCR.use_cassette 'media/remove_tag' do
      Flickrie.add_media_tags(@media_id, "janko")
      media = Flickrie.get_media_info(@media_id)
      tags_before_change = media.tags.join(' ')
      tag_id = media.tags.find { |tag| tag.content == "janko" }.id
      Flickrie.remove_media_tag(tag_id)
      media.get_info
      assert_equal media.tags.join(' '), tags_before_change.chomp("janko").rstrip
    end
  end

  def test_delete_media
    VCR.use_cassette 'media/delete' do
      media_path = File.join(File.expand_path(File.dirname(__FILE__)), 'photo.jpg')
      media_id = Flickrie.upload(media_path)
      assert_includes Flickrie.public_media_from_user(@user_nsid).map(&:id), media_id
      Flickrie.delete_media(media_id)
      refute_includes Flickrie.public_media_from_user(@user_nsid).map(&:id), media_id
    end
  end

  def test_media_from_contacts
    VCR.use_cassette 'media/from_contacts' do
      medias = [
        Flickrie.media_from_contacts(
          :include_self => 1, :single_photo => 1, :extras => @all_extras).first,
        Flickrie.public_media_from_user_contacts(@user_nsid,
          :include_self => 1, :single_photo => 1, :extras => @all_extras).first
      ]

      medias.each do |media|
        assert_equal '7093101501', media.id
        assert_equal '9337f28800', media.secret
        assert_equal '7090', media.server
        assert_equal 8, media.farm
        assert_equal 'IMG_0917', media.title
        assert_equal '', media.tags.join(' ')
        assert_equal '', media.machine_tags.join(' ')
        assert_equal 0, media.views_count
        assert_equal '0', media.license.id
        assert_not_nil media.url
        assert_equal 'ready', media.media_status

        # Time
        assert_instance_of Time, media.uploaded_at
        assert_instance_of Time, media.updated_at
        assert_instance_of Time, media.taken_at
        assert_equal 0, media.taken_at_granularity

        # Location
        assert_nil media.location

        # Owner
        assert_equal '67131352@N04', media.owner.nsid
        assert_equal 'Janko Marohnić', media.owner.username
        assert_equal '5464', media.owner.icon_server
        assert_equal 6, media.owner.icon_farm
        refute media.owner.buddy_icon_url.empty?

        # Visibility (This is the difference from Flickrie.media_from_set)
        assert_equal true, media.visibility.public?
        assert_equal false, media.visibility.friends?
        assert_equal false, media.visibility.family?
        assert_equal nil, media.visibility.contacts?
      end
    end
  end

  def test_get_media_context
    VCR.use_cassette 'media/get_context' do
      context = Flickrie.get_media_context(@media_id)

      assert_equal 98, context['count']

      previous_media = context['prevphoto']
      assert_equal '6946978706', previous_media.id
      assert_equal 'b38270bbd6', previous_media.secret
      assert_equal '7216', previous_media.server
      assert_equal 8, previous_media.farm
      assert_equal 'IMG_0795', previous_media.title
      refute previous_media.url.empty?
      assert_equal '0', previous_media.license.id
      assert_equal false, previous_media.faved?

      next_media = context['nextphoto']
      assert_equal '6946979704', next_media.id
      assert_equal '74513ff732', next_media.secret
      assert_equal '7234', next_media.server
      assert_equal 8, next_media.farm
      assert_equal 'IMG_0797', next_media.title
      refute next_media.url.empty?
      assert_equal '0', next_media.license.id
      assert_equal false, next_media.faved?
    end
  end

  def test_media_replace
    VCR.use_cassette 'media/replace' do
      media_path = File.join(File.expand_path(File.dirname(__FILE__)), 'photo.jpg')
      begin
        media_id = Flickrie.upload(media_path)
        Flickrie.replace(media_path, media_id)
        flunk
      rescue => exception
        assert_equal "Not a pro account", exception.message
      ensure
        Flickrie.delete_media(media_id)
      end
    end
  end

  def test_methods_returning_nil
    media = Flickrie::Photo.new

    assert_nil media.id
    assert_nil media.secret
    assert_nil media.server
    assert_nil media.farm
    assert_nil media.title
    assert_nil media.description
    assert_nil media.tags
    assert_nil media.machine_tags
    assert_nil media.media_status
    assert_nil media.path_alias
    assert_nil media.views_count
    assert_nil media.comments_count
    assert_nil media.location
    assert_nil media.geo_permissions
    assert_nil media.license
    assert_nil media.posted_at
    assert_nil media.uploaded_at
    assert_nil media.updated_at
    assert_nil media.taken_at
    assert_nil media.taken_at_granularity
    assert_nil media.owner
    assert_nil media.safety_level
    assert_nil media.safe?
    assert_nil media.moderate?
    assert_nil media.restricted?
    assert_nil media.url
    assert_nil media.visibility
    assert_nil media.primary?
    assert_nil media.favorite?
    assert_nil media.can_comment?
    assert_nil media.can_add_meta?
    assert_nil media.can_everyone_comment?
    assert_nil media.can_everyone_add_meta?
    assert_nil media.can_download?
    assert_nil media.can_blog?
    assert_nil media.can_print?
    assert_nil media.can_share?
    assert_nil media.has_people?
    assert_nil media.notes
    assert_nil media.media_status
  end
end

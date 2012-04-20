# encoding: utf-8
require 'test/unit'
require 'flickr'

class MediaTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
    @item_id = 6946979188
    @set_id = 72157629851991663
    @user_nsid = '67131352@N04'

    # license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o
    @all_extras = %w[license date_upload date_taken owner_name
      icon_server original_format last_update geo tags machine_tags
      o_dims views media path_alias
      url_sq url_q url_t url_s url_n url_m url_z url_c url_l url_o]
  end

  def test_get_media_info
    item = Flickr.get_item_info(@item_id)

    assert_equal '6946979188', item.id
    assert_equal '25bb44852b', item.secret
    assert_equal '7049', item.server
    assert_equal 8, item.farm
    assert_equal 'IMG_0796', item.title
    assert_equal 'luka', item.tags
    assert_equal '', item.machine_tags
    assert_equal 1, item.views_count
    assert_equal 1, item.comments_count
    assert_equal '0', item.license.id
    assert_equal 0, item.safety_level
    assert_equal 90, item.rotation
    assert_equal 'Test', item.description
    assert_not_nil item.url

    # Time
    assert_instance_of Time, item.uploaded_at
    assert_instance_of Time, item.updated_at
    assert_instance_of Time, item.taken_at
    assert_equal 0, item.taken_at_granularity
    assert_instance_of Time, item.posted_at

    # Owner
    assert_equal '67131352@N04', item.owner.nsid
    assert_equal 'Janko Marohnić', item.owner.username
    assert_equal 'Janko Marohnić', item.owner.real_name
    assert_equal 'Zagreb, Croatia', item.owner.location
    assert_equal '5464', item.owner.icon_server
    assert_equal 6, item.owner.icon_farm
    refute item.owner.buddy_icon_url.empty?

    # Predicates
    assert_equal true, item.visibility.public?
    assert_equal false, item.visibility.friends?
    assert_equal false, item.visibility.family?
    assert_equal nil, item.visibility.contacts?

    assert_equal false, item.can_comment?
    assert_equal false, item.can_add_meta?
    assert_equal true, item.can_everyone_comment?
    assert_equal false, item.can_everyone_add_meta?

    assert_equal true, item.can_download?
    assert_equal false, item.can_blog?
    assert_equal false, item.can_print?
    assert_equal false, item.can_share?

    assert_equal false, item.has_people?

    assert_equal true, item.safe?
    assert_equal false, item.moderate?
    assert_equal false, item.restricted?

    assert_equal false, item.favorite?

    assert_equal true, item.geo_permissions.public?
    assert_equal false, item.geo_permissions.contacts?
    assert_equal false, item.geo_permissions.friends?
    assert_equal false, item.geo_permissions.family?

    # Notes
    note = item.notes.first
    assert_equal '72157629487842968', note.id
    assert_equal '67131352@N04', note.author.nsid
    assert_equal 'Janko Marohnić', note.author.username
    assert_equal [316, 0], note.coordinates
    assert_equal [59, 50], [note.width, note.height]
    assert_equal 'Test', note.content

    # Location
    location = item.location

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

  def test_items_from_set
    item = Flickr.items_from_set(@set_id, :extras => @all_extras.join(',')).
      find { |item| item.id.to_i == @item_id }

    assert_equal '6946979188', item.id
    assert_equal '25bb44852b', item.secret
    assert_equal '7049', item.server
    assert_equal 8, item.farm
    assert_equal 'IMG_0796', item.title
    assert_equal 'luka', item.tags
    assert_equal '', item.machine_tags
    assert_equal 1, item.views_count
    assert_equal '0', item.license.id
    assert_equal true, item.primary?
    assert_not_nil item.url
    assert_equal 'ready', item.media_status

    # Time
    assert_instance_of Time, item.uploaded_at
    assert_instance_of Time, item.updated_at
    assert_instance_of Time, item.taken_at
    assert_equal 0, item.taken_at_granularity

    # Location
    assert_equal 45.807258, item.location.latitude
    assert_equal 15.967599, item.location.longitude
    assert_equal '11', item.location.accuracy
    assert_equal '0', item.location.context.to_s
    assert_equal '00j4IylZV7scWik', item.location.place_id
    assert_equal '851128', item.location.woeid
    assert_equal true, item.geo_permissions.public?
    assert_equal false, item.geo_permissions.contacts?
    assert_equal false, item.geo_permissions.friends?
    assert_equal false, item.geo_permissions.family?

    # Owner
    assert_equal '67131352@N04', item.owner.nsid
    assert_equal 'Janko Marohnić', item.owner.username
    assert_equal '5464', item.owner.icon_server
    assert_equal 6, item.owner.icon_farm
    refute item.owner.buddy_icon_url.empty?
  end

  def test_public_items_from_user
    item = Flickr.public_items_from_user(@user_nsid, :extras => @all_extras).
      find { |item| item.id.to_i == @item_id }

    assert_equal '6946979188', item.id
    assert_equal '25bb44852b', item.secret
    assert_equal '7049', item.server
    assert_equal 8, item.farm
    assert_equal 'IMG_0796', item.title
    assert_equal 'luka', item.tags
    assert_equal '', item.machine_tags
    assert_equal 1, item.views_count
    assert_equal '0', item.license.id
    assert_not_nil item.url
    assert_equal 'ready', item.media_status

    # Time
    assert_instance_of Time, item.uploaded_at
    assert_instance_of Time, item.updated_at
    assert_instance_of Time, item.taken_at
    assert_equal 0, item.taken_at_granularity

    # Location
    assert_equal 45.807258, item.location.latitude
    assert_equal 15.967599, item.location.longitude
    assert_equal '11', item.location.accuracy
    assert_equal '0', item.location.context.to_s
    assert_equal '00j4IylZV7scWik', item.location.place_id
    assert_equal '851128', item.location.woeid
    assert_equal true, item.geo_permissions.public?
    assert_equal false, item.geo_permissions.contacts?
    assert_equal false, item.geo_permissions.friends?
    assert_equal false, item.geo_permissions.family?

    # Owner
    assert_equal '67131352@N04', item.owner.nsid
    assert_equal 'Janko Marohnić', item.owner.username
    assert_equal '5464', item.owner.icon_server
    assert_equal 6, item.owner.icon_farm
    refute item.owner.buddy_icon_url.empty?

    # Visibility (This is the difference from Flickr.items_from_set)
    assert_equal true, item.visibility.public?
    assert_equal false, item.visibility.friends?
    assert_equal false, item.visibility.family?
    assert_equal nil, item.visibility.contacts?
  end

  def test_methods_returning_nil
    item = Flickr::Photo.new

    assert_nil item.id
    assert_nil item.secret
    assert_nil item.server
    assert_nil item.farm
    assert_nil item.title
    assert_nil item.description
    assert_nil item.tags
    assert_nil item.machine_tags
    assert_nil item.media_status
    assert_nil item.path_alias
    assert_nil item.views_count
    assert_nil item.comments_count
    assert_nil item.location
    assert_nil item.geo_permissions
    assert_nil item.license
    assert_nil item.posted_at
    assert_nil item.uploaded_at
    assert_nil item.updated_at
    assert_nil item.taken_at
    assert_nil item.taken_at_granularity
    assert_nil item.owner
    assert_nil item.safety_level
    assert_nil item.safe?
    assert_nil item.moderate?
    assert_nil item.restricted?
    assert_nil item.url
    assert_nil item.visibility
    assert_nil item.primary?
    assert_nil item.favorite?
    assert_nil item.can_comment?
    assert_nil item.can_add_meta?
    assert_nil item.can_everyone_comment?
    assert_nil item.can_everyone_add_meta?
    assert_nil item.can_download?
    assert_nil item.can_blog?
    assert_nil item.can_print?
    assert_nil item.can_share?
    assert_nil item.has_people?
    assert_nil item.notes
    assert_nil item.media_status
  end
end

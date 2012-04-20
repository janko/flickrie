# encoding: utf-8
require 'test/unit'
require 'flickr'
require 'flickr/photo'
require 'flickr/client'
require 'flickr/user'
require 'flickr/license'

class PhotoTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
    @photo_id = 6946979188
    @set_id = 72157629851991663
    @user_nsid = '67131352@N04'

    # license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o
    @all_extras = %w[license date_upload date_taken owner_name
      icon_server original_format last_update geo tags machine_tags
      o_dims views media path_alias
      url_sq url_q url_t url_s url_n url_m url_z url_c url_l url_o]
  end

  def test_get_photo_info
    photo = Flickr.get_photo_info(@photo_id)

    assert_equal '6946979188', photo.id
    assert_equal '25bb44852b', photo.secret
    assert_equal '7049', photo.server
    assert_equal 8, photo.farm
    assert_equal 'IMG_0796', photo.title
    assert_equal 'luka', photo.tags
    assert_equal '', photo.machine_tags
    assert_equal 1, photo.views_count
    assert_equal 1, photo.comments_count
    assert_equal '0', photo.license.id
    assert_equal 0, photo.safety_level
    assert_equal 90, photo.rotation
    assert_equal 'Test', photo.description
    assert_not_nil photo.url

    # Time
    assert_instance_of Time, photo.uploaded_at
    assert_instance_of Time, photo.updated_at
    assert_instance_of Time, photo.taken_at
    assert_equal 0, photo.taken_at_granularity
    assert_instance_of Time, photo.posted_at

    # Owner
    assert_equal '67131352@N04', photo.owner.nsid
    assert_equal 'Janko Marohnić', photo.owner.username
    assert_equal 'Janko Marohnić', photo.owner.real_name
    assert_equal 'Zagreb, Croatia', photo.owner.location
    assert_equal '5464', photo.owner.icon_server
    assert_equal 6, photo.owner.icon_farm
    refute photo.owner.buddy_icon_url.empty?

    # Predicates
    assert_equal true, photo.visibility.public?
    assert_equal false, photo.visibility.friends?
    assert_equal false, photo.visibility.family?
    assert_equal nil, photo.visibility.contacts?

    assert_equal false, photo.can_comment?
    assert_equal false, photo.can_add_meta?
    assert_equal true, photo.can_everyone_comment?
    assert_equal false, photo.can_everyone_add_meta?

    assert_equal true, photo.can_download?
    assert_equal false, photo.can_blog?
    assert_equal false, photo.can_print?
    assert_equal false, photo.can_share?

    assert_equal false, photo.has_people?

    assert_equal true, photo.safe?
    assert_equal false, photo.moderate?
    assert_equal false, photo.restricted?

    assert_equal false, photo.favorite?

    assert_equal true, photo.geo_permissions.public?
    assert_equal false, photo.geo_permissions.contacts?
    assert_equal false, photo.geo_permissions.friends?
    assert_equal false, photo.geo_permissions.family?

    # Notes
    note = photo.notes.first
    assert_equal '72157629487842968', note.id
    assert_equal '67131352@N04', note.author.nsid
    assert_equal 'Janko Marohnić', note.author.username
    assert_equal [316, 0], note.coordinates
    assert_equal [59, 50], [note.width, note.height]
    assert_equal 'Test', note.content

    # Location
    location = photo.location

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

    # Attributes that are supposed to be blank
    assert_equal [], photo.available_sizes
    assert_equal nil, photo.size

    [
      photo.square(75), photo.square(150), photo.thumbnail,
      photo.small(240), photo.small(320), photo.medium(500),
      photo.medium(640), photo.medium(800), photo.large(1024),
      photo.original, photo.square75, photo.square150,
      photo.small240, photo.small320, photo.medium500,
      photo.medium640, photo.medium800, photo.large1024,
      photo.largest
    ].
      each do |photo|
        assert_nil photo.source_url
        assert_nil photo.width
        assert_nil photo.height
      end

    [
      proc { photo.square!(75) }, proc { photo.square!(150) },
      proc { photo.thumbnail! }, proc { photo.small!(240) },
      proc { photo.small!(320) }, proc { photo.medium!(500) },
      proc { photo.medium!(640) }, proc { photo.medium!(800) },
      proc { photo.large!(1024) }, proc { photo.original! },
      proc { photo.square75! }, proc { photo.square150! },
      proc { photo.small240! }, proc { photo.small320! },
      proc { photo.medium500! }, proc { photo.medium640! },
      proc { photo.medium800! }, proc { photo.large1024! },
      proc { photo.largest! }
    ].
      each do |prok|
        prok.call
        assert_nil photo.source_url
        assert_nil photo.width
        assert_nil photo.height
      end
  end

  def test_photos_from_set_with_extras
    photo = Flickr.photos_from_set(@set_id, :extras => @all_extras.join(',')).
      find { |photo| photo.id.to_i == @photo_id }

    assert_equal '6946979188', photo.id
    assert_equal '25bb44852b', photo.secret
    assert_equal '7049', photo.server
    assert_equal 8, photo.farm
    assert_equal 'IMG_0796', photo.title
    assert_equal 'luka', photo.tags
    assert_equal '', photo.machine_tags
    assert_equal 1, photo.views_count
    assert_equal '0', photo.license.id
    assert_equal true, photo.primary?
    assert_not_nil photo.url
    assert_equal 'ready', photo.media_status

    # Time
    assert_instance_of Time, photo.uploaded_at
    assert_instance_of Time, photo.updated_at
    assert_instance_of Time, photo.taken_at
    assert_equal 0, photo.taken_at_granularity

    # Location
    assert_equal 45.807258, photo.location.latitude
    assert_equal 15.967599, photo.location.longitude
    assert_equal '11', photo.location.accuracy
    assert_equal '0', photo.location.context.to_s
    assert_equal '00j4IylZV7scWik', photo.location.place_id
    assert_equal '851128', photo.location.woeid
    assert_equal true, photo.geo_permissions.public?
    assert_equal false, photo.geo_permissions.contacts?
    assert_equal false, photo.geo_permissions.friends?
    assert_equal false, photo.geo_permissions.family?

    # Owner
    assert_equal '67131352@N04', photo.owner.nsid
    assert_equal 'Janko Marohnić', photo.owner.username
    assert_equal '5464', photo.owner.icon_server
    assert_equal 6, photo.owner.icon_farm
    refute photo.owner.buddy_icon_url.empty?

    assert_sizes(photo)
  end

  def test_public_photos_from_user
    photo = Flickr.public_photos_from_user(@user_nsid, :extras => @all_extras).
      find { |photo| photo.id.to_i == @photo_id }

    assert_equal '6946979188', photo.id
    assert_equal '25bb44852b', photo.secret
    assert_equal '7049', photo.server
    assert_equal 8, photo.farm
    assert_equal 'IMG_0796', photo.title
    assert_equal 'luka', photo.tags
    assert_equal '', photo.machine_tags
    assert_equal 1, photo.views_count
    assert_equal '0', photo.license.id
    assert_not_nil photo.url
    assert_equal 'ready', photo.media_status

    # Time
    assert_instance_of Time, photo.uploaded_at
    assert_instance_of Time, photo.updated_at
    assert_instance_of Time, photo.taken_at
    assert_equal 0, photo.taken_at_granularity

    # Location
    assert_equal 45.807258, photo.location.latitude
    assert_equal 15.967599, photo.location.longitude
    assert_equal '11', photo.location.accuracy
    assert_equal '0', photo.location.context.to_s
    assert_equal '00j4IylZV7scWik', photo.location.place_id
    assert_equal '851128', photo.location.woeid
    assert_equal true, photo.geo_permissions.public?
    assert_equal false, photo.geo_permissions.contacts?
    assert_equal false, photo.geo_permissions.friends?
    assert_equal false, photo.geo_permissions.family?

    # Owner
    assert_equal '67131352@N04', photo.owner.nsid
    assert_equal 'Janko Marohnić', photo.owner.username
    assert_equal '5464', photo.owner.icon_server
    assert_equal 6, photo.owner.icon_farm
    refute photo.owner.buddy_icon_url.empty?

    # Visibility (This is the difference from Flickr.photos_from_set)
    assert_equal true, photo.visibility.public?
    assert_equal false, photo.visibility.friends?
    assert_equal false, photo.visibility.family?
    assert_equal nil, photo.visibility.contacts?

    assert_sizes(photo, :exclude => ['Square 150', 'Small 320', 'Medium 800'])
  end

  def test_get_photo_sizes
    photo = Flickr.get_photo_sizes(@photo_id)

    assert_equal '6946979188', photo.id
    assert_equal true, photo.can_download?
    assert_equal false, photo.can_blog?
    assert_equal false, photo.can_print?

    assert_sizes(photo)
  end

  def assert_sizes(photo, options = {})
    options[:exclude] ||= []
    [
      [[photo.square(75), photo.square75],   ['Square 75', '75x75']],
      [[photo.thumbnail],                    ['Thumbnail', '75x100']],
      [[photo.square(150), photo.square150], ['Square 150', '150x150']],
      [[photo.small(240), photo.small240],   ['Small 240', '180x240']],
      [[photo.small(320), photo.small320],   ['Small 320', '240x320']],
      [[photo.medium(500), photo.medium500], ['Medium 500', '375x500']],
      [[photo.medium(640), photo.medium640], ['Medium 640', '480x640']],
      [[photo.medium(800), photo.medium800], ['Medium 800', '600x800']],
      [[photo.large(1024), photo.large1024], ['Large 1024', '768x1024']]
    ].
      reject { |_, expected_values| options[:exclude].include?(expected_values.first) }.
      each do |photos, expected_values|
        flickr_size, size = expected_values
        photos.each do |photo|
          assert_equal flickr_size, photo.size
          assert_equal size, "#{photo.width}x#{photo.height}", "Non bang versions"
          refute photo.source_url.empty?
        end
      end

    [
      [[proc { photo.square!(75) }, proc { photo.square75! }],   ['Square 75', '75x75']],
      [[proc { photo.thumbnail! }],                              ['Thumbnail', '75x100']],
      [[proc { photo.square!(150) }, proc { photo.square150! }], ['Square 150', '150x150']],
      [[proc { photo.small!(240) }, proc { photo.small240! }],   ['Small 240', '180x240']],
      [[proc { photo.small!(320) }, proc { photo.small320! }],   ['Small 320', '240x320']],
      [[proc { photo.medium!(500) }, proc { photo.medium500! }], ['Medium 500', '375x500']],
      [[proc { photo.medium!(640) }, proc { photo.medium640! }], ['Medium 640', '480x640']],
      [[proc { photo.medium!(800) }, proc { photo.medium800! }], ['Medium 800', '600x800']],
      [[proc { photo.large!(1024) }, proc { photo.large1024! }], ['Large 1024', '768x1024']]
    ].
      reject { |_, expected_values| options[:exclude].include?(expected_values.first) }.
      each do |proks, expected_values|
        flickr_size, size = expected_values
        proks.each do |prok|
          prok.call
          assert_equal flickr_size, photo.size
          assert_equal size, "#{photo.width}x#{photo.height}", "Bang versions"
          refute photo.source_url.empty?
        end
      end
  end

  def test_methods_returning_nil
    photo = Flickr::Photo.new

    assert_nil photo.id
    assert_nil photo.secret
    assert_nil photo.server
    assert_nil photo.farm
    assert_nil photo.title
    assert_nil photo.description
    assert_nil photo.tags
    assert_nil photo.machine_tags
    assert_nil photo.media_status
    assert_nil photo.path_alias
    assert_nil photo.views_count
    assert_nil photo.comments_count
    assert_nil photo.location
    assert_nil photo.geo_permissions
    assert_nil photo.license
    assert_nil photo.posted_at
    assert_nil photo.uploaded_at
    assert_nil photo.updated_at
    assert_nil photo.taken_at
    assert_nil photo.taken_at_granularity
    assert_nil photo.owner
    assert_nil photo.safety_level
    assert_nil photo.safe?
    assert_nil photo.moderate?
    assert_nil photo.restricted?
    assert_nil photo.url
    assert_nil photo.visibility
    assert_nil photo.primary?
    assert_nil photo.favorite?
    assert_nil photo.can_comment?
    assert_nil photo.can_add_meta?
    assert_nil photo.can_everyone_comment?
    assert_nil photo.can_everyone_add_meta?
    assert_nil photo.can_download?
    assert_nil photo.can_blog?
    assert_nil photo.can_print?
    assert_nil photo.can_share?
    assert_nil photo.has_people?
    assert_nil photo.notes
    assert_nil photo.media_status

    assert_nil photo.width
    assert_nil photo.height
    assert_nil photo.source_url
    assert_nil photo.rotation
  end
end

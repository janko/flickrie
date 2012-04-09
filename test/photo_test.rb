require 'test/unit'
require 'flickr/photo'

class PhotoTest < Test::Unit::TestCase
  include Flickr

  def Photo.public_new(*args)
    new(*args)
  end

  def setup
    @hash ||= {'id' => "12", 'title' => "Some title",
               'width_sq' => "75", 'height_sq' => "75", 'url_sq' => "Square 75 URL",
               'width_q' => "150", 'height_q' => "150", 'url_q' => "Square 150 URL"}
  end

  def test_initialize
    assert_raises(Photo::InvalidSize) { Photo.public_new(@hash, 'Thumbnail') }
    assert_nothing_raised { Photo.public_new(@hash, 'Square 75') }
    assert_equal 'Square 150', Photo.public_new(@hash).size
  end

  def test_attributes
    photo = Photo.public_new(@hash)
    assert_equal 12, photo.id
    assert_equal "Some title", photo.title
    photo = photo.square75
    assert_equal 75, photo.width
    assert_equal 75, photo.height
    assert_equal "Square 75 URL", photo.url
    photo = photo.square150
    assert_equal 150, photo.width
    assert_equal 150, photo.height
    assert_equal "Square 150 URL", photo.url
  end

  def test_methods
    photo = Photo.public_new(@hash)
    assert_equal ["Square 75", "Square 150"], photo.available_sizes
    assert_equal "Square 75", photo.square75.size
    assert_nil photo.thumbnail
    assert_equal "Square 150", photo.largest.size
  end
end

# encoding: utf-8
require 'test/unit'
require 'flickr/client'

class ClientTest < Test::Unit::TestCase
  def setup
    Flickr.api_key = ENV['FLICKR_API_KEY']
  end

  def test_internals
    assert_equal ENV['FLICKR_API_KEY'], Flickr.api_key
    assert_instance_of Flickr::Client, Flickr.client
  end

  def test_api_calls
  end
end

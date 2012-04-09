module Flickr
  class << self
    attr_accessor :api_key
  end
end

require 'flickr/client'
require 'flickr/photo'
require 'flickr/methods'

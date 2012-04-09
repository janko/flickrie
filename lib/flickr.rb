require 'faraday_stack'
require 'flickr/client'
require 'flickr/photo'

module Flickr
  class << self
    attr_accessor :api_key

    def photos_from_set(set_id)
      response = client.photos_from_set(set_id)
      response.body['photoset']['photo'].map do |hash|
        Photo.new(hash)
      end
    end
  end
end

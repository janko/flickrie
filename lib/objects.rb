module Flickr
  class Object
    def self.new_collection(array)
      array.map { |hash| new(hash) }
    end
  end
end

require 'photo'
require 'photoset'

module Flickrie
  class MediaContext
    # @return [Fixnum]
    attr_reader :count
    # @return [Flickrie::Photo, Flickrie::Video]
    attr_reader :previous
    # @return [Flickrie::Photo, Flickrie::Video]
    attr_reader :next

    def initialize(hash, api_caller)
      count = hash['count'].to_i
      previous = hash['prevphoto']['id'].to_i > 0 ? Media.new(hash['prevphoto'], api_caller) : nil
      next_ = hash['nextphoto']['id'].to_i > 0 ? Media.new(hash['nextphoto'], api_caller) : nil
      @count, @previous, @next = count, previous, next_
    end
  end
end

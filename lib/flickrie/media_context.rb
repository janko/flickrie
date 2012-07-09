module Flickrie
  class MediaContext
    # @return [Fixnum]
    attr_reader :count
    # @return [Flickrie::Photo, Flickrie::Video]
    attr_reader :previous
    # @return [Flickrie::Photo, Flickrie::Video]
    attr_reader :next

    def initialize(hash, api_caller)
      count = hash['count']['_content'].to_i
      previous = Media.new(hash['prevphoto'], api_caller) rescue nil
      next_ = Media.new(hash['nextphoto'], api_caller) rescue nil
      @count, @previous, @next = count, previous, next_
    end
  end
end

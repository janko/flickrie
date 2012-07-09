module Flickrie
  class Ticket
    # @!parse attr_reader \
    #   :id, :media_id, :complete?, :imported_at, :hash

    # @return [String]
    def id()       @info['id']      end
    # @return [String]
    def media_id() @info['photoid'] end
    alias photo_id media_id
    alias video_id media_id

    # @return [Boolean]
    def complete?() Integer(@info['complete']) == 1 rescue nil end

    # @return [Time]
    def imported_at() Time.at(Integer(@info['imported'])) rescue nil end

    def [](key) @info[key] end
    # @return [Hash]
    def hash() @info end

    private

    def initialize(info)
      @info = info
    end
  end
end

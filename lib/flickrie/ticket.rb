module Flickrie
  class Ticket
    # @!parse attr_reader :id
    def id()       @info['id']      end
    # @!parse attr_reader :media_id
    def media_id() @info['photoid'] end
    alias photo_id media_id
    alias video_id media_id

    # @!parse attr_reader :complete?
    def complete?() Integer(@info['complete']) == 1 rescue nil end

    # @!parse attr_reader :imported_at
    def imported_at() Time.at(Integer(@info['imported'])) rescue nil end

    def [](key) @info[key] end
    # @!parse attr_reader :hash
    def hash() @info end

    private

    def initialize(info)
      @info = info
    end
  end
end

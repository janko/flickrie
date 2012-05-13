module Flickrie
  class Ticket
    def id()       @info['id']      end
    def media_id() @info['photoid'] end
    alias photo_id media_id
    alias video_id media_id

    def complete?() Integer(@info['complete']) == 1 rescue nil end

    def imported_at() Time.at(Integer(@info['imported'])) rescue nil end

    def [](key) @info[key] end
    def hash() @info end

    private

    def initialize(info)
      @info = info
    end
  end
end

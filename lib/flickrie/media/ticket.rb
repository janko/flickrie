module Flickrie
  module Media
    class Ticket
      def id; @info['id'] end
      def media_id; @info['photoid'] end
      alias photo_id media_id
      alias video_id media_id

      def complete?
        @info['complete'].to_i == 1
      end

      def imported_at
        Time.at(@info['imported'].to_i)
      end

      def [](key)
        @info[key]
      end

      def initialize(info)
        @info = info
      end
    end
  end
end

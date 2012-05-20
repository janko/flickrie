module Flickrie
  module Media
    class Note
      # @!parse attr_reader \
      #   :id, :author, :content, :coordinates, :width,
      #   :height, :hash

      # @return [String]
      def id() @info['id'] end
      # @return [Flickrie::User]
      def author() User.new('nsid' => @info['author'], 'username' => @info['authorname']) end
      # @return [String]
      def content() @info['_content'] end
      # Returns a 2-element array, representing a point.
      #
      # @return [Array<Fixnum>]
      def coordinates() [@info['x'].to_i, @info['y'].to_i] end
      # @return [Fixnum]
      def width() @info['w'].to_i end
      # @return [Fixnum]
      def height() @info['h'].to_i end

      def to_s
        content
      end

      def [](key) @info[key] end
      # @return [Fixnum]
      def hash() @info end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

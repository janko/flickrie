module Flickrie
  module Media
    class Note
      # @!parse attr_reader \
      #   :id, :author, :content, :coordinates, :width,
      #   :height, :hash

      # @return [String]
      def id() @hash['id'] end
      # @return [Flickrie::User]
      def author() User.new('nsid' => @info['author'], 'username' => @info['authorname']) end
      # @return [String]
      def content() @hash['_content'] end
      # Returns a 2-element array, representing a point.
      #
      # @return [Array<Fixnum>]
      def coordinates() [@hash['x'].to_i, @hash['y'].to_i] end
      # @return [Fixnum]
      def width() @hash['w'].to_i end
      # @return [Fixnum]
      def height() @hash['h'].to_i end

      def to_s
        content
      end

      def [](key) @hash[key] end
      # @return [Fixnum]
      def hash() @hash end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

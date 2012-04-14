module Flickr
  module Media
    class Note
      attr_reader :id, :author, :coordinates, :content

      Coordinate = Struct.new(:bottom_left, :top_right)

      def to_s
        @content
      end

      def initialize(hash)
        @id = hash['id'].to_i
        @author = User.new \
          'nsid' => hash['author'],
          'username' => hash['authorname']
        @content = hash['_content']

        coordinates = ['x', 'y', 'w', 'h'].map { |l| hash[l].to_i}
        @coordinates = Coordinate.new \
          coordinates.first(2), coordinates.last(2)
      end
    end
  end
end

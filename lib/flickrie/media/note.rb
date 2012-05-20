module Flickrie
  module Media
    class Note
      attr_reader :id, :author, :coordinates, :content,
        :width, :height

      def to_s
        @content
      end

      def [](key) @info[key] end
      # @!parse attr_reader :hash
      def hash() @info end

      private

      def initialize(hash)
        @id = hash['id']
        @author = User.new \
          'nsid' => hash['author'],
          'username' => hash['authorname']
        @content = hash['_content']
        @coordinates = [hash['x'].to_i, hash['y'].to_i]
        @width = hash['w'].to_i
        @height = hash['h'].to_i
      end
    end
  end
end

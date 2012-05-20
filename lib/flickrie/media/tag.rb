module Flickrie
  module Media
    class Tag
      # @!parse attr_reader :id
      def id()      @info['id']       end
      # @!parse attr_reader :raw
      def raw()     @info['raw']      end
      # @!parse attr_reader :content
      def content() @info['_content'] end

      # @!parse attr_reader :machine_tag?
      def machine_tag?
        @info['machine_tag'].to_i == 1 if @info['machine_tag']
      end

      # @!parse attr_reader :author
      def author
        User.new('nsid' => @info['author']) if @info['author']
      end

      def [](key) @info[key] end
      # @!parse attr_reader :hash
      def hash() @info end

      private

      def initialize(info)
        @info = info
      end

      def to_s
        content
      end
    end
  end
end

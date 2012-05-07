module Flickrie
  module Media
    class Tag
      def id;      @info['id']       end
      def raw;     @info['raw']      end
      def content; @info['_content'] end

      def machine_tag?
        @info['machine_tag'].to_i == 1 if @info['machine_tag']
      end

      def author
        User.new('nsid' => @info['author']) if @info['author']
      end

      def [](key)
        @info[key]
      end

      def initialize(info)
        @info = info
      end

      def to_s
        content
      end
    end
  end
end

module Flickrie
  module Media
    class Tag
      def id;      @info['id']       end
      def raw;     @info['raw']      end
      def content; @info['_content'] end

      def machine_tag?
        @info['machine_tag'].to_i == 1
      end

      def author
        User.new('nsid' => @info['author'])
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

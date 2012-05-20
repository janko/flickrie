module Flickrie
  module Media
    class Tag
      # @!parse attr_reader \
      #   :id, :raw, :content, :machine_tag?, :author, :hash

      # @return [String]
      def id()      @info['id']       end
      # @return [String]
      def raw()     @info['raw']      end
      # @return [String]
      def content() @info['_content'] end

      # @return [Boolean]
      def machine_tag?
        @info['machine_tag'].to_i == 1 if @info['machine_tag']
      end

      # @return [Flickrie::User]
      def author
        User.new('nsid' => @info['author']) if @info['author']
      end

      def [](key) @info[key] end
      # @return [Hash]
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

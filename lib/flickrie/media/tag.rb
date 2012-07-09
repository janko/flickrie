module Flickrie
  module Media
    class Tag
      # @!parse attr_reader \
      #   :id, :raw, :content, :machine_tag?, :author, :hash

      # @return [String]
      def id()      @hash['id']       end
      # @return [String]
      def raw()     @hash['raw']      end
      # @return [String]
      def content() @hash['_content'] end

      # @return [Boolean]
      def machine_tag?
        @hash['machine_tag'].to_i == 1 if @hash['machine_tag']
      end

      # @return [Flickrie::User]
      def author
        User.new('nsid' => @info['author']) if @info['author']
      end

      def [](key) @hash[key] end
      # @return [Hash]
      def hash() @hash end

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

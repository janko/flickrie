module Flickrie
  module Media
    class Exif
      def get(key, options = {})
        hash = @info.find { |hash| hash['label'] == key }
        data = hash[options[:data]] || hash['clean'] || hash['raw']
        data['_content']

      rescue NoMethodError
        nil
      end

      def [](key) @info[key] end
      def hash() @info end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

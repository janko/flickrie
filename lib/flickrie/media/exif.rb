module Flickrie
  module Media
    class Exif
      def get(key, options = {})
        hash = @info.find { |hash| hash['label'] == key }
        data = hash[options[:data]] || hash['clean'] || hash['raw']
        data['_content']

      rescue NoMethodError
        raise Error, "The information about '#{key}' doesn't exist"
      end

      def [](key)
        @info[key]
      end

      def initialize(info)
        @info = info
      end
    end
  end
end

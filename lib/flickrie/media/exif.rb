module Flickrie
  module Media
    class Exif
      # Gets exif. Example:
      #
      #     photo.exif.get('Model') # => 'Canon PowerShot G12'
      #
      #     photo.exif.get('X-Resolution', :data => 'raw')   # => '180'
      #     photo.exif.get('X-Resolution', :data => 'clean') # => '180 dpi'
      #     photo.exif.get('X-Resolution')                   # => '180 dpi'
      #
      #
      def get(key, options = {})
        hash = @info.find { |hash| hash['label'] == key }
        data = hash[options[:data]] || hash['clean'] || hash['raw']
        data['_content']

      rescue NoMethodError
        nil
      end

      def [](key) @info[key] end
      # @!parse attr_reader :hash
      def hash() @info end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

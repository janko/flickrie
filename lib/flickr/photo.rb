require 'flickr/media'

module Flickr
  class Photo
    include Media

    attr_reader :size

    SIZES = {
      'Square 75'  => 'sq',
      'Square 150' => 'q',
      'Thumbnail'  => 't',
      'Small 240'  => 's',
      'Small 320'  => 'n',
      'Medium 500' => 'm',
      'Medium 640' => 'z',
      'Medium 800' => 'c',
      'Large 1024' => 'l',
      'Original'   => 'o'
    }

    def square(number); self.class.new(@info, "Square #{number}") end
    def thumbnail;      self.class.new(@info, "Thumbnail")        end
    def small(number);  self.class.new(@info, "Small #{number}")  end
    def medium(number); self.class.new(@info, "Medium #{number}") end
    def large(number);  self.class.new(@info, "Large #{number}")  end
    def original;       self.class.new(@info, "Original")         end

    def square!(number); @size = "Square #{number}"; self end
    def thumbnail!;      @size = "Thumbnail";        self end
    def small!(number);  @size = "Small #{number}";  self end
    def medium!(number); @size = "Medium #{number}"; self end
    def large!(number);  @size = "Large #{number}";  self end
    def original!;       @size = "Original";         self end

    def largest; self.class.new(@info, largest_size) end
    def largest!; @size = largest_size; self end

    def available_sizes
      SIZES.select { |_, s| @info["url_#{s}"] }.keys
    end

    def width;      @info["width_#{size_abbr}"].to_i  end
    def height;     @info["height_#{size_abbr}"].to_i end
    def source_url; @info["url_#{size_abbr}"]         end

    def rotation; @info['rotation'].to_i end

    private

    def initialize(hash, size = nil)
      super(hash)
      @size = size || largest_size
    end

    def largest_size
      available_sizes.last
    end

    def size_abbr
      SIZES[size]
    end
  end
end

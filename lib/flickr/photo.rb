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

    def square!(number); @size = "Square #{number}"; self end
    def thumbnail!;      @size = "Thumbnail";        self end
    def small!(number);  @size = "Small #{number}";  self end
    def medium!(number); @size = "Medium #{number}"; self end
    def large!(number);  @size = "Large #{number}";  self end
    def original!;       @size = "Original";         self end

    def square(number); self.class.new(@info).square!(number) end
    def thumbnail;      self.class.new(@info).thumbnail!      end
    def small(number);  self.class.new(@info).small!(number)  end
    def medium(number); self.class.new(@info).medium!(number) end
    def large(number);  self.class.new(@info).large!(number)  end
    def original;       self.class.new(@info).original!       end

    def largest!; @size = largest_size; self end
    def largest; self.class.new(@info).largest! end

    def available_sizes
      SIZES.select { |_, s| @info["url_#{s}"] }.keys
    end

    def width;      @info["width_#{size_abbr}"].to_i  end
    def height;     @info["height_#{size_abbr}"].to_i end
    def source_url; @info["url_#{size_abbr}"]         end

    def rotation; @info['rotation'].to_i end

    def get_sizes(info = nil)
      info ||= Flickr.client.get_photo_sizes(id).body['sizes']
      unless @info['usage']
        @info['usage'] = {
          'canblog'     => info['canblog'],
          'canprint'    => info['canprint'],
          'candownload' => info['candownload']
        }
      end
      flickr_sizes = {
        'Square' => 'sq',
        'Large Square' => 'q',
        'Thumbnail' => 't',
        'Small' => 's',
        'Small 320' => 'n',
        'Medium' => 'm',
        'Medium 640' => 'z',
        'Medium 800' => 'c',
        'Large' => 'l',
        'Original' => 'o'
      }
      info['size'].each do |size_info|
        size_abbr = flickr_sizes[size_info['label']]
        @info["width_#{size_abbr}"] = size_info['width']
        @info["height_#{size_abbr}"] = size_info['height']
        @info["url_#{size_abbr}"] = size_info['source']
      end

      self
    end

    private

    def initialize(info = {}, size = nil)
      @info = info
      @size = size || largest_size
    end

    def self.from_sizes(info)
      new.get_sizes(info)
    end

    def largest_size
      available_sizes.last
    end

    def size_abbr
      SIZES[size]
    end
  end
end

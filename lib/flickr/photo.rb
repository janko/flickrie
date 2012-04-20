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

    def square(number); dup.square!(number) end
    def thumbnail;      dup.thumbnail!      end
    def small(number);  dup.small!(number)  end
    def medium(number); dup.medium!(number) end
    def large(number);  dup.large!(number)  end
    def original;       dup.original!       end

    [75, 150].each do |n|
      define_method("square#{n}!") { square!(n) }
      define_method("square#{n}") { square(n) }
    end
    [240, 320].each do |n|
      define_method("small#{n}!") { small!(n) }
      define_method("small#{n}") { small(n) }
    end
    [500, 640, 800].each do |n|
      define_method("medium#{n}!") { medium!(n) }
      define_method("medium#{n}") { medium(n) }
    end
    [1024].each do |n|
      define_method("large#{n}!") { large!(n) }
      define_method("large#{n}") { large(n) }
    end

    def largest!; @size = largest_size; self end
    def largest;  dup.largest! end

    def available_sizes
      SIZES.select { |_, s| @info["url_#{s}"] }.keys
    end

    def width;      @info["width_#{size_abbr}"].to_i if @info["width_#{size_abbr}"]   end
    def height;     @info["height_#{size_abbr}"].to_i if @info["height_#{size_abbr}"] end

    def source_url; @info["url_#{size_abbr}"] end

    def rotation; @info['rotation'].to_i if @info['rotation'] end

    def get_sizes(info = nil)
      info ||= Flickr.client.get_media_sizes(id).body['sizes']
      @info['usage'].update \
        'canblog'     => info['canblog'],
        'canprint'    => info['canprint'],
        'candownload' => info['candownload']
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

      @size = largest_size
      self
    end

    private

    def initialize(info = {}, size = nil)
      super(info)
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

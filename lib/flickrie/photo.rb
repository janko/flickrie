module Flickrie
  class Photo
    include Media
    # @!parse attr_reader \
    #   :size, :width, :height, :source_url, :rotation

    SIZES = {
      'Square 75'  => 'sq',
      'Thumbnail'  => 't',
      'Square 150' => 'q',
      'Small 240'  => 's',
      'Small 320'  => 'n',
      'Medium 500' => 'm',
      'Medium 640' => 'z',
      'Medium 800' => 'c',
      'Large 1024' => 'l',
      'Original'   => 'o'
    }

    # Returns the current Flickr size of the photo ("Medium 500", for example).
    #
    # @return [String]
    def size() @size end

    # @return [self]
    def square!(number) @size = "Square #{number}"; self end
    # @return [self]
    def thumbnail!()    @size = "Thumbnail";        self end
    # @return [self]
    def small!(number)  @size = "Small #{number}";  self end
    # @return [self]
    def medium!(number) @size = "Medium #{number}"; self end
    # @return [self]
    def large!(number)  @size = "Large #{number}";  self end
    # @return [self]
    def original!()     @size = "Original";         self end

    # @return [self]
    def square(number) dup.square!(number) end
    # @return [self]
    def thumbnail()    dup.thumbnail!      end
    # @return [self]
    def small(number)  dup.small!(number)  end
    # @return [self]
    def medium(number) dup.medium!(number) end
    # @return [self]
    def large(number)  dup.large!(number)  end
    # @return [self]
    def original()     dup.original!       end

    # @comment Alternate size methods
    # @return [self]
    def square75()   square(75)   end
    # @return [self]
    def square75!()  square!(75)  end
    # @return [self]
    def square150()  square(150)  end
    # @return [self]
    def square150!() square!(150) end
    # @return [self]
    def small240()   small(240)   end
    # @return [self]
    def small240!()  small!(240)  end
    # @return [self]
    def small320()   small(320)   end
    # @return [self]
    def small320!()  small!(320)  end
    # @return [self]
    def medium500()  medium(500)  end
    # @return [self]
    def medium500!() medium!(500) end
    # @return [self]
    def medium640()  medium(640)  end
    # @return [self]
    def medium640!() medium!(640) end
    # @return [self]
    def medium800()  medium(800)  end
    # @return [self]
    def medium800!() medium!(800) end
    # @return [self]
    def large1024()  large(1024)  end
    # @return [self]
    def large1024!() large!(1024) end

    # @return [self]
    def largest!() @size = largest_size; self end
    # @return [self]
    def largest()  dup.largest! end

    # @return [Array<String>]
    def available_sizes
      SIZES.select { |_,v| @info["url_#{v}"] }.keys
    end

    # @return [Fixnum]
    def width() flickr_size.min rescue nil end
    # @return [Fixnum]
    def height() flickr_size.max rescue nil end
    # @return [String]
    def source_url() @info["url_#{size_abbr}"] end

    # @return [Fixnum]
    def rotation() Integer(@info['rotation']) rescue nil end

    # Same as calling `Flickrie.get_photo_sizes(photo.id)`.
    #
    # @return [self]
    def get_sizes(params = {}, info = nil)
      info ||= Flickrie.client.get_media_sizes(id, params).body['sizes']
      @info['usage'] ||= {}
      @info['usage'].update \
        'canblog'     => info['canblog'],
        'canprint'    => info['canprint'],
        'candownload' => info['candownload']
      flickr_sizes = {
        'Square'       => SIZES['Square 75'],
        'Large Square' => SIZES['Square 150'],
        'Thumbnail'    => SIZES['Thumbnail'],
        'Small'        => SIZES['Small 240'],
        'Small 320'    => SIZES['Small 320'],
        'Medium'       => SIZES['Medium 500'],
        'Medium 640'   => SIZES['Medium 640'],
        'Medium 800'   => SIZES['Medium 800'],
        'Large'        => SIZES['Large 1024'],
        'Original'     => SIZES['Original']
      }
      info['size'].each do |size_info|
        size_abbr = flickr_sizes[size_info['label']]
        @info["width_#{size_abbr}"] = size_info['width']
        @info["height_#{size_abbr}"] = size_info['height']
        @info["url_#{size_abbr}"] = size_info['source']
      end

      largest!
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

    def flickr_size
      [Integer(@info["width_#{size_abbr}"]), Integer(@info["height_#{size_abbr}"])]
    end
  end
end

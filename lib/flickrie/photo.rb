module Flickrie
  class Photo
    include Media
    # @!parse attr_reader \
    #   :size, :width, :height, :source_url, :rotation

    FLICKR_SIZES = {
      'Square 75'  => 'sq',
      'Thumbnail'  => 't',
      'Square 150' => 'q',
      'Small 240'  => 's',
      'Small 320'  => 'n',
      'Medium 500' => 'm',
      'Medium 640' => 'z',
      'Medium 800' => 'c',
      'Large 1024' => 'l',
      'Large 1600' => 'h',
      'Large 2048' => 'k',
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

    # @return [self]
    def square75()   square(75)   end
    # @return [self]
    def square150()  square(150)  end
    # @return [self]
    def small240()   small(240)   end
    # @return [self]
    def small320()   small(320)   end
    # @return [self]
    def medium500()  medium(500)  end
    # @return [self]
    def medium640()  medium(640)  end
    # @return [self]
    def medium800()  medium(800)  end
    # @return [self]
    def large1024()  large(1024)  end
    # @return [self]
    def large1600()  large(1600)  end
    # @return [self]
    def large2048()  large(2048)  end

    # @return [self]
    def square75!()  square!(75)  end
    # @return [self]
    def square150!() square!(150) end
    # @return [self]
    def small240!()  small!(240)  end
    # @return [self]
    def small320!()  small!(320)  end
    # @return [self]
    def medium500!() medium!(500) end
    # @return [self]
    def medium640!() medium!(640) end
    # @return [self]
    def medium800!() medium!(800) end
    # @return [self]
    def large1024!() large!(1024) end
    # @return [self]
    def large1600!() large!(1600) end
    # @return [self]
    def large2048!() large!(2048) end

    # @return [self]
    def largest!() @size = largest_size; self end
    # @return [self]
    def largest()  dup.largest! end

    # @return [Array<String>]
    def available_sizes
      FLICKR_SIZES.select { |_,v| @hash["url_#{v}"] }.keys
    end

    # @return [Fixnum]
    def width() Integer(@hash["width_#{size_abbr}"]) rescue nil end
    # @return [Fixnum]
    def height() Integer(@hash["height_#{size_abbr}"]) rescue nil end
    # @return [String]
    def source_url() @hash["url_#{size_abbr}"] end

    # @return [Fixnum]
    def rotation() Integer(@hash['rotation']) rescue nil end

    # Same as calling `Flickrie.get_photo_sizes(photo.id)`.
    #
    # @return [self]
    def get_sizes(params = {})
      @hash.deep_merge!(@api_caller.get_photo_sizes(id, params).hash)
      largest!
    end

    private

    def initialize(*args)
      super
      @size = largest_size
    end

    def largest_size
      available_sizes.last
    end

    def size_abbr
      FLICKR_SIZES[size]
    end
  end
end

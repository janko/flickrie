module Flickrie
  class Photo
    include Media

    attr_reader :size

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

    def square!(number) @size = "Square #{number}"; self end
    def thumbnail!()    @size = "Thumbnail";        self end
    def small!(number)  @size = "Small #{number}";  self end
    def medium!(number) @size = "Medium #{number}"; self end
    def large!(number)  @size = "Large #{number}";  self end
    def original!()     @size = "Original";         self end

    def square(number) dup.square!(number) end
    def thumbnail()    dup.thumbnail!      end
    def small(number)  dup.small!(number)  end
    def medium(number) dup.medium!(number) end
    def large(number)  dup.large!(number)  end
    def original()     dup.original!       end

    #--
    # Alternate size methods
    def square75()   square(75)   end
    def square75!()  square!(75)  end
    def square150()  square(150)  end
    def square150!() square!(150) end
    def small240()   small(240)   end
    def small240!()  small!(240)  end
    def small320()   small(320)   end
    def small320!()  small!(320)  end
    def medium500()  medium(500)  end
    def medium500!() medium!(500) end
    def medium640()  medium(640)  end
    def medium640!() medium!(640) end
    def medium800()  medium(800)  end
    def medium800!() medium!(800) end
    def large1024()  large(1024)  end
    def large1024!() large!(1024) end

    def largest!() @size = largest_size; self end
    def largest()  dup.largest! end

    def available_sizes
      SIZES.select { |_,v| @info["url_#{v}"] }.keys
    end

    def width()  Integer(@info["width_#{size_abbr}"])  rescue nil end
    def height() Integer(@info["height_#{size_abbr}"]) rescue nil end
    def source_url() @info["url_#{size_abbr}"] end

    def rotation() Integer(@info['rotation']) rescue nil end

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
  end
end

module Flickr
  class Photo
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

    attr_reader :size

    def id
      @hash['id'].to_i
    end

    def title
      @hash['title']
    end

    def available_sizes
      SIZES.select { |_, size_abbr| @hash["url_#{size_abbr}"] }.keys
    end

    SIZES.keys.each do |size|
      define_method(size.downcase.delete(' ')) do
        Photo.new(@hash, size) rescue nil
      end
    end

    def largest
      Photo.new(@hash, largest_size)
    end

    def width
      @hash["width_#{size_abbr}"].to_i
    end

    def height
      @hash["height_#{size_abbr}"].to_i
    end

    def url
      @hash["url_#{size_abbr}"]
    end

    def to_s
      url
    end

    def inspect
      attributes = %w[size url width height].inject({}) do |hash, attr|
        hash.update(attr => send(attr))
      end
      %(#<Photo: #{attributes.map { |k, v| %(#{k}="#{v}") }.join(", ")}>)
    end

    class InvalidSize < ArgumentError
    end

    private

    def initialize(hash, size = nil)
      @hash = hash
      @size = size || largest_size

      unless available_sizes.include?(@size)
        raise InvalidSize, "size \"#{@size}\" isn't available for this photo"
      end
    end

    def size_abbr
      SIZES[@size]
    end

    def largest_size
      available_sizes.last
    end
  end
end

require 'object'

module Flickr
  class Photo < Flickr::Object
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

    def square(number)
      Photo.new(@hash, "Square #{number}")
    end

    def thumbnail
      Photo.new(@hash, "Thumbnail")
    end

    def small(number)
      Photo.new(@hash, "Small #{number}")
    end

    def medium(number)
      Photo.new(@hash, "Medium #{number}")
    end

    def large(number)
      Photo.new(@hash, "Large #{number}")
    end

    def original
      Photo.new(@hash, "Original")
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

__END__

{
  "id" => "6913731566",
  "secret" => "23879c079a",
  "server" => "7130",
  "farm" => 8,
  "dateuploaded" => "1333956611",
  "isfavorite" => 0,
  "license" => "0",
  "safety_level" => "0",
  "rotation" => 0,
  "owner" => {
    "nsid" => "67131352@N04",
    "username" => "Janko Marohnić",
    "realname" => "",
    "location" => "",
    "iconserver" => "0",
    "iconfarm" => 0
  },
  "title" => {"_content" => "6913664138_61ffb9c0d7_b"},
  "description" => {"_content" => ""},
  "visibility" => {"ispublic" => 1, "isfriend" => 0, "isfamily" => 0},
  "dates" => {
    "posted" => "1333956611",
    "taken" => "2012-04-09 00:30:11",
    "takengranularity" => "0",
    "lastupdate" => "1333956616"
  },
  "views" => "0",
  "editability" => {"cancomment" => 0, "canaddmeta" => 0},
  "publiceditability" => {"cancomment" => 1, "canaddmeta" => 0},
  "usage" => {"candownload" => 1, "canblog" => 0, "canprint" => 0, "canshare" => 0},
  "comments" => {"_content" => "0"},
  "notes" => {"note" => []},
  "people" => {"haspeople" => 0},
  "tags" => {"tag" => []},
  "urls "=> {
    "url"=> [
      {
        "type"=>"photopage",
       "_content"=>"http://www.flickr.com/photos/67131352@N04/6913731566/"
      }
    ]
  },
  "media"=>"photo"}
}

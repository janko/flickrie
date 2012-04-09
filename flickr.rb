require 'faraday_stack'

module Flickr
  class << self
    attr_accessor :api_key

    def client
      @client ||= FaradayStack::build Client,
        :url => 'http://api.flickr.com/services/rest/',
        :params => {
          :format => 'json',
          :nojsoncallback => '1',
          :api_key => self.api_key
        },
        request: {
          :open_timeout => 2,
          :timeout => 3
        }
    end

    def photos_from_set(set_id)
      response = client.photos_from_set(set_id)
      response.body['photoset']['photo'].map do |hash|
        Photo.new(hash)
      end
    end
  end

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
        Photo.new(@hash, size)
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

      if not available_sizes.include?(@size)
        raise InvalidSize, "size \"#{@size}\" isn't available"
      end
    end

    def size_abbr
      SIZES[@size]
    end

    def largest_size
      available_sizes.last
    end
  end

  class Error < StandardError
  end

  class StatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      unless env[:body]['stat'] == 'ok'
        raise Error, env[:body]['message']
      end
    end
  end

  class Client < Faraday::Connection
    def get(method, params)
      super() do |req|
        req.params[:method] = method.to_s
        req.params.update params
      end
    end

    def find_person_by_email(email)
      get 'flickr.people.findByEmail', :find_email => email
    end

    def photos_from_set(photoset_id)
      get 'flickr.photosets.getPhotos', :photoset_id => photoset_id,
        :extras => 'url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o'
    end

    def photo_sizes(photo_id)
      get 'flickr.photos.getSizes', :photo_id => photo_id
    end

    def photo_info(photo_id)
      get 'flickr.photos.getInfo', :photo_id => photo_id
    end
  end
end

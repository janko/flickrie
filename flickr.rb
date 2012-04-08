require 'faraday_stack'
require 'securerandom'
require 'active_support/notifications'
require 'active_support/cache'

ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
end

module Flickr
  def self.client
    @client ||= begin
      client = FaradayStack::build Client,
        url: 'http://api.flickr.com/services/rest/',
        params: {
          format: 'json',
          nojsoncallback: '1',
          api_key: ENV["FLICKR_API_KEY"]
        },
        request: {
          open_timeout: 2,
          timeout: 3
        }

      cache = ActiveSupport::Cache::FileStore.new File.join(ENV['TMPDIR'], 'juris-cache'),
          namespace: 'juris', expires_in: 60 * 60 * 24 * 7

      client.builder.insert_before FaradayStack::ResponseJSON, FaradayStack::Caching,
          cache, strip_params: %w[ api_key format nojsoncallback ]

      client.builder.insert_before FaradayStack::ResponseJSON, FaradayStack::Instrumentation
      client.builder.insert_before FaradayStack::ResponseJSON, StatusCheck
      client
    end
  end

  def self.photos_from_set(set_id)
    response = client.photos_from_set(set_id)
    response.body['photoset']['photo'].map do |hash|
      Photo.new(hash)
    end
  end

  def self.find_photo(photo_id)
    response_sizes = client.photo_sizes(photo_id)
    response_info = client.photo_info(photo_id)
    id = response_info.body['photo']['id']
    title = response_info.body['photo']['title']['_content']
    Photo.from_sizes response_sizes.body['sizes']['size'], title, id
  end

  class Photo
    SIZES = %w[ o l z m s t sq ]
    SIZE_NAMES = {
      'square'    => 'sq',
      'thumbnail' => 't',
      'small'     => 's',
      'medium500' => 'm',
      'medium640' => 'z',
      'large'     => 'l',
      'original'  => 'o'
    }

    def self.from_sizes(sizes, title, id)
      new sizes.each_with_object({}) { |data, hash|
        label = data['label']
        label = 'Medium 500' if data['label'] == 'Medium'
        size = SIZE_NAMES[label.downcase.delete(' ')]
        hash["url_#{size}"] = data['source']
        hash["width_#{size}"] = data['width']
        hash["height_#{size}"] = data['height']
        hash['title'] = title
        hash['id'] = id
      }
    end

    def initialize(hash, size = nil)
      @hash = hash
      @size = size || detect_largest_size
    end

    def id
      @hash['id']
    end

    def title
      @hash['title']
    end

    def available_sizes
      SIZES.reverse.take(@hash.count {|key, value| key =~ /url/}).map {|size| SIZE_NAMES.key(size)}
    end

    def size
      SIZE_NAMES.key @size
    end

    def largest_size
      SIZE_NAMES.key(detect_largest_size)
    end

    SIZE_NAMES.each do |name, size|
      define_method(name) do
        photo = Photo.new(@hash, size)
        photo.url ? photo : nil
      end
    end

    def largest
      Photo.new(@hash)
    end

    def width
      Integer(@hash["width_#{@size}"])
    end

    def height
      Integer(@hash["height_#{@size}"])
    end

    def url
      @hash["url_#{@size}"]
    end

    def to_s
      url
    end

    def medium640_or_less
      medium640 || medium500 || small || thumbnail || square
    end

    private

    def detect_largest_size
      SIZES.detect {|s| @hash["url_#{s}"] }
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

    # {
    #   "user": {
    #     "id": "67131352@N04",
    #     "nsid": "67131352@N04",
    #     "username": {
    #       "_content": "Janko Marohnić"
    #     }
    #   },
    #   "stat": "ok"
    # }
    def find_person_by_email(email)
      get 'flickr.people.findByEmail', find_email: email
    end

    def photos_from_set(set_id)
      get 'flickr.photosets.getPhotos', photoset_id: set_id.to_s,
        extras: 'url_sq,url_t,url_s,url_m,url_z,url_l,url_o'
    end

    def photo_sizes(photo_id)
      get 'flickr.photos.getSizes', photo_id: photo_id.to_s
    end

    def photo_info(photo_id)
      get 'flickr.photos.getInfo', photo_id: photo_id.to_s
    end
  end
end

__END__
photoset_id=72157627460265059

{"photoset"=>
  {"id"=>"72157627460265059",
   "primary"=>"6109216253",
   "owner"=>"67131352@N04",
   "ownername"=>"Janko Marohnić",
   "photo"=>
    [{"id"=>"6109212429",
      "secret"=>"8bbec8c624",
      "server"=>"6208",
      "farm"=>7,
      "title"=>"1",
      "isprimary"=>"0",
      "url_sq"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_s.jpg",
      "height_sq"=>75,
      "width_sq"=>75,
      "url_t"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_t.jpg",
      "height_t"=>"67",
      "width_t"=>"100",
      "url_s"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_m.jpg",
      "height_s"=>"161",
      "width_s"=>"240",
      "url_m"=>"http://farm7.static.flickr.com/6208/6109212429_8bbec8c624.jpg",
      "height_m"=>"335",
      "width_m"=>"500"}

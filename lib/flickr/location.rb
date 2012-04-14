module Flickr
  class Location
    def id; @info['place_id'] end

    %w[latitude longitude accuracy context woeid].each do |attr_name|
      define_method(attr_name) do
        @info[attr_name]
      end
    end

    %w[neighbourhood locality county region country].each do |place_name|
      define_method(place_name) do
        place = Struct.new(:name, :id, :woeid)
        place.new \
          @info[place_name]['_content'],
          @info[place_name]['place_id'],
          @info[place_name]['woeid']
      end
    end

    private

    def initialize(info)
      @info = info
    end
  end
end

__END__

{
  "latitude" => 37.792608,
  "longitude" => -122.402672,
  "accuracy" => "14",
  "context" => "0",
  "neighbourhood" => {
    "_content" => "Financial District",
    "place_id" => "GddgqTpTUb8LgT93hw",
    "woeid" => "23512022"
  },
  "locality" => {
    "_content" => "San Francisco",
    "place_id" => "7.MJR8tTVrIO1EgB",
    "woeid" => "2487956"
  },
  "county" => {
    "_content" => "San Francisco",
    "place_id" => ".7sOmlRQUL9nK.kMzA",
    "woeid" => "12587707"
  },
  "region" => {
    "_content" => "California",
    "place_id" => "NsbUWfBTUb4mbyVu",
    "woeid" => "2347563"
  },
  "country" => {
    "_content" => "United States",
    "place_id" => "nz.gsghTUb4c2WAecA",
    "woeid" => "23424977"
  },
  "place_id" =>"GddgqTpTUb8LgT93hw",
  "woeid" =>"23512022"
}

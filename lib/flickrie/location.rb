module Flickrie
  class Location
    %w[latitude longitude accuracy context place_id woeid].each do |attr_name|
      define_method(attr_name) do
        @info[attr_name]
      end
    end

    %w[neighbourhood locality county region country].each do |place_name|
      define_method(place_name) do
        if @info[place_name]
          Struct.new(:name, :place_id, :woeid).new \
            @info[place_name]['_content'],
            @info[place_name]['place_id'],
            @info[place_name]['woeid']
        end
      end
    end

    def [](key)
      @info[key]
    end

    private

    def initialize(info = {})
      @info = info
    end
  end
end

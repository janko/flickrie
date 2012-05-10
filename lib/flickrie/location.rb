module Flickrie
  class Location
    attr_reader :latitude, :longitude, :accuracy, :context, :place_id,
      :woeid

    def neighbourhood() place('neighbourhood') end
    def locality()      place('locality')      end
    def county()        place('county')        end
    def region()        place('region')        end
    def country()       place('country')       end

    def [](key)
      @info[key]
    end

    private

    def initialize(info = {})
      raise ArgumentError if info.nil?

      @info = info

      %w[latitude longitude accuracy context place_id woeid].each do |attribute|
        instance_variable_set "@#{attribute}", @info[attribute]
      end
    end

    def place(place_name)
      if @info[place_name]
        Struct.new(:name, :place_id, :woeid).new \
          @info[place_name]['_content'],
          @info[place_name]['place_id'],
          @info[place_name]['woeid']
      end
    end
  end
end

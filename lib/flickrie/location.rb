module Flickrie
  class Location
    # @!parse attr_reader :latitude
    def latitude()  @info['latitude']  end
    # @!parse attr_reader :longitude
    def longitude() @info['longitude'] end
    # @!parse attr_reader :accuracy
    def accuracy()  @info['accuracy']  end
    # @!parse attr_reader :context
    def context()   Integer(@info['context']) rescue nil end

    # @!parse attr_reader :neighbourhood
    def neighbourhood() new_area('neighbourhood') end
    # @!parse attr_reader :locality
    def locality()      new_area('locality')      end
    # @!parse attr_reader :county
    def county()        new_area('county')        end
    # @!parse attr_reader :region
    def region()        new_area('region')        end
    # @!parse attr_reader :country
    def country()       new_area('country')       end

    # @!parse attr_reader :place_id
    def place_id() @info['place_id'] end
    # @!parse attr_reader :woeid
    def woeid()    @info['woeid']    end

    def [](key) @info[key] end
    # @!parse attr_reader :hash
    def hash() @info end

    private

    def initialize(info = {})
      raise ArgumentError if info.nil?
      @info = info
    end

    def new_area(area_name)
      if @info[area_name]
        area_class = Class.new(Struct.new(:name, :place_id, :woeid)) do
          def to_s
            name
          end
        end
        info = @info[area_name]
        area_class.new(info['_content'], info['place_id'], info['woeid'])
      end
    end
  end
end

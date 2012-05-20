module Flickrie
  class Location
    # @!parse attr_reader \
    #   :latitude, :longitude, :accuracy, :context,
    #   :neighbourhood, :locality, :county, :region,
    #   :country, :place_id, :woeid, :hash

    # @return [Fixnum]
    def latitude()  @info['latitude']  end
    # @return [Fixnum]
    def longitude() @info['longitude'] end
    # @return [String]
    def accuracy()  @info['accuracy']  end
    # @return [Fixnum]
    def context()   Integer(@info['context']) rescue nil end

    # Returns a struct with attributes `#name`, `#place_id` and `#woeid`
    #
    # @return [Struct]
    def neighbourhood() new_area('neighbourhood') end
    # Returns a struct with attributes `#name`, `#place_id` and `#woeid`
    #
    # @return [Struct]
    def locality()      new_area('locality')      end
    # Returns a struct with attributes `#name`, `#place_id` and `#woeid`
    #
    # @return [Struct]
    def county()        new_area('county')        end
    # Returns a struct with attributes `#name`, `#place_id` and `#woeid`
    #
    # @return [Struct]
    def region()        new_area('region')        end
    # Returns a struct with attributes `#name`, `#place_id` and `#woeid`
    #
    # @return [Struct]
    def country()       new_area('country')       end

    # @return [String]
    def place_id() @info['place_id'] end
    # @return [String]
    def woeid()    @info['woeid']    end

    def [](key) @info[key] end
    # Returns the raw hash from the response. Useful if something isn't available by methods.
    #
    # @return [Hash]
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

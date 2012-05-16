module Flickrie
  class Location
    def latitude()  @info['latitude']  end
    def longitude() @info['longitude'] end
    def accuracy()  @info['accuracy']  end
    def context()   Integer(@info['context']) rescue nil end

    def neighbourhood() new_area('neighbourhood') end
    def locality()      new_area('locality')      end
    def county()        new_area('county')        end
    def region()        new_area('region')        end
    def country()       new_area('country')       end

    def place_id() @info['place_id'] end
    def woeid()    @info['woeid']    end

    def [](key) @info[key] end
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

module Flickrie
  module Media
    class Visibility
      def public?()   @info['ispublic'].to_i == 1 if @info['ispublic']   end
      def friends?()  @info['isfriend'].to_i == 1 if @info['isfriend']   end
      def family?()   @info['isfamily'].to_i == 1 if @info['isfamily']   end
      def contacts?() @info['iscontact'].to_i == 1 if @info['iscontact'] end

      def [](key)
        @info[key]
      end

      def initialize(info)
        @info = info
      end
    end
  end
end

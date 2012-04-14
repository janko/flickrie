module Flickr
  module Media
    class Visibility
      def public?;   @public == 1   end
      def friends?;  @friends == 1  end
      def family?;   @family == 1   end
      def contacts?; @contacts == 1 end

      def initialize(*visibility)
        @public   = visibility[0].to_i
        @friends  = visibility[1].to_i
        @family   = visibility[2].to_i
        @contacts = visibility[3].to_i
      end
    end
  end
end

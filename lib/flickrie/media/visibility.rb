module Flickrie
  module Media
    class Visibility
      def public?;   @visibility[0].to_i == 1 if @visibility[0]   end
      def friends?;  @visibility[1].to_i == 1 if @visibility[1]   end
      def family?;   @visibility[2].to_i == 1 if @visibility[2]   end
      def contacts?; @visibility[3].to_i == 1 if @visibility[3]   end

      def initialize(*visibility)
        @visibility = visibility.flatten
      end
    end
  end
end

module Flickrie
  module Media
    class Visibility
      # @!parse attr_reader \
      #   :public?, :friends?, :family?, :contacts?, :hash

      # @return [Boolean]
      def public?()   @info['ispublic'].to_i == 1 if @info['ispublic']   end
      # @return [Boolean]
      def friends?()  @info['isfriend'].to_i == 1 if @info['isfriend']   end
      # @return [Boolean]
      def family?()   @info['isfamily'].to_i == 1 if @info['isfamily']   end
      # @return [Boolean]
      def contacts?() @info['iscontact'].to_i == 1 if @info['iscontact'] end

      def [](key) @info[key] end
      # @return [Hash]
      def hash() @info end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

module Flickrie
  module Media
    class Visibility
      # @!parse attr_reader :public?
      def public?()   @info['ispublic'].to_i == 1 if @info['ispublic']   end
      # @!parse attr_reader :friends?
      def friends?()  @info['isfriend'].to_i == 1 if @info['isfriend']   end
      # @!parse attr_reader :family?
      def family?()   @info['isfamily'].to_i == 1 if @info['isfamily']   end
      # @!parse attr_reader :contacts?
      def contacts?() @info['iscontact'].to_i == 1 if @info['iscontact'] end

      def [](key) @info[key] end
      # @!parse attr_reader :hash
      def hash() @info end

      private

      def initialize(info)
        raise ArgumentError if info.nil?

        @info = info
      end
    end
  end
end

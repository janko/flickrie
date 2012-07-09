module Flickrie
  module Media
    class Visibility
      # @!parse attr_reader \
      #   :public?, :friends?, :family?, :contacts?, :hash

      # @return [Boolean]
      def public?()   @hash['ispublic'].to_i == 1 if @hash['ispublic']   end
      # @return [Boolean]
      def friends?()  @hash['isfriend'].to_i == 1 if @hash['isfriend']   end
      # @return [Boolean]
      def family?()   @hash['isfamily'].to_i == 1 if @hash['isfamily']   end
      # @return [Boolean]
      def contacts?() @hash['iscontact'].to_i == 1 if @hash['iscontact'] end

      def [](key) @hash[key] end
      # @return [Hash]
      def hash() @hash end

      private

      def initialize(hash)
        raise ArgumentError if hash.nil?
        @hash = hash
      end
    end
  end
end

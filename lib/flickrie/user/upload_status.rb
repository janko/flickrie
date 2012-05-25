module Flickrie
  class User
    class UploadStatus
      # @!parse attr_reader :bandwidth, :maximum_photo_size,
      #   :maximum_video_size, :videos_uploaded, :videos_remaining,
      #   :sets_created, :sets_remaining

      # Returns the monthly bandwidth. Example:
      #
      #     user.bandwidth.maximum    # => 300
      #     user.bandwidth.used       # => 120
      #     user.bandwidth.remaining  # => 180
      #     user.bandwidth.unlimited? # => false
      #
      # All numbers are in megabytes
      #
      # @return [Class]
      def bandwidth
        bandwidth = Class.new do
          def maximum()   @hash['maxkb'].to_f / 1024       end
          def used()      @hash['usedkb'].to_f / 1024      end
          def remaining() @hash['remainingkb'].to_f / 1024 end

          def unlimited?()  @hash['unlimited'].to_i == 1 end

          def initialize(hash)
            raise ArgumentError if hash.nil?
            @hash = hash
          end
        end

        bandwidth.new(@hash['bandwidth']) rescue nil
      end

      # @return [Fixnum] In megabytes
      def maximum_photo_size() Integer(@hash['filesize']['maxmb'])   rescue nil end
      # @return [Fixnum] In megabytes
      def maximum_video_size() Integer(@hash['videosize']['maxmb'])  rescue nil end
      # @return [Fixnum]
      def videos_uploaded()    Integer(@hash['videos']['uploaded'])  rescue nil end
      # @return [Fixnum]
      def videos_remaining()   Integer(@hash['videos']['remaining']) rescue nil end
      # @return [Fixnum]
      def sets_created()       Integer(@hash['sets']['created'])     rescue nil end
      # @return [Fixnum, String]
      def sets_remaining()     @hash['sets']['remaining']            rescue nil end

      def initialize(hash)
        raise ArgumentError if hash.nil?
        @hash = hash
      end
    end
  end
end

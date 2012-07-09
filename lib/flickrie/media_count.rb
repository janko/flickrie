require 'date'

module Flickrie
  class MediaCount
    # @!parse attr_reader \
    #   :value, :date_range, :from, :to, :hash

    def value() Integer(@hash['count']) rescue nil end

    # @return [Range]
    def date_range
      dates = []
      ['fromdate', 'todate'].each do |key|
        if @hash[key] == @hash[key].to_i.to_s
          dates << Time.at(Integer(@hash[key]))
        else
          dates << DateTime.parse(@hash[key]).to_time
        end
      end

      dates.first..dates.last
    end
    alias time_interval date_range

    # @return [Time]
    def from() date_range.begin end
    # @return [Time]
    def to()   date_range.end   end

    def [](key) @hash[key] end
    # Returns the raw hash from the response. Useful if something isn't available by methods.
    #
    # @return [Hash]
    def hash() @hash end

    private

    def initialize(hash)
      @hash = hash
    end

    def self.new_collection(hash)
      hash['photocount'].map { |info| new(info) }
    end
  end
end

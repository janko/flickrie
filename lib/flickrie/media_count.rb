require 'date'

module Flickrie
  class MediaCount
    def value
      @info['count'].to_i
    end

    def date_range
      dates =
        case @dates_kind
        when "mysql timestamp"
          [DateTime.parse(@info['fromdate']).to_time,
           DateTime.parse(@info['todate']).to_time]
        when "unix timestamp"
          [Time.at(@info['fromdate'].to_i),
           Time.at(@info['todate'].to_i)]
        end

      dates.first..dates.last
    end

    def initialize(info, params)
      @info = info
      @dates_kind = (params[:dates].nil? ? "mysql timestamp" : "unix timestamp")
    end
  end
end

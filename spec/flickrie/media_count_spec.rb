require 'spec_helper'

describe :MediaCount do
  context "get", :vcr do
    let(:dates) { [DateTime.parse("1st March 2012"), DateTime.parse("5th May 2012")].map(&:to_time) }
    let(:counts) {
      [
        Flickrie.get_media_counts(:taken_dates => dates.join(',')).first,
        Flickrie.get_media_counts(:dates => dates.map(&:to_i).join(',')).first
      ]
    }

    it "has correct attributes" do
      counts.each do |count|
        count.value.should be_an_instance_of(Fixnum)

        count.date_range.begin.should eq(dates.first)
        count.from.should eq(dates.first)

        count.date_range.end.should eq(dates.last)
        count.to.should eq(dates.last)
      end
    end
  end
end

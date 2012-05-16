require File.expand_path("../../spec_helper", __FILE__)

describe Flickrie::MediaCount do
  context "get" do
    it "should have correctly set all attributes", :vcr do
      dates = [DateTime.parse("1st March 2012"), DateTime.parse("5th May 2012")].map(&:to_time)
      [
        @flickrie.get_media_counts(:taken_dates => dates.join(',')).first,
        @flickrie.get_media_counts(:dates => dates.map(&:to_i).join(',')).first
      ].
        each do |count|
          count.value.should be_an_instance_of(Fixnum)
          count.date_range.begin.should eq(dates.first)
          count.date_range.end.should eq(dates.last)
        end
    end
  end
end
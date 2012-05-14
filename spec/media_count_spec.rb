require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Flickrie::MediaCount do
  context "get" do
    use_vcr_cassette "media_count/get"

    it "should have correctly set all attributes" do
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

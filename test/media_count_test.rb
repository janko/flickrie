class MediaCountTest < Test::Unit::TestCase
  def test_get
    VCR.use_cassette 'media_count/get' do
      dates = [DateTime.parse("1st March 2012"), DateTime.parse("5th May 2012")].map(&:to_time)

      count = Flickrie.get_media_counts(:taken_dates => dates.join(',')).first
      assert_instance_of Fixnum, count.value
      assert_equal dates.first, count.date_range.begin
      assert_equal dates.last, count.date_range.end

      count = Flickrie.get_media_counts(:dates => dates.map(&:to_i).join(',')).first
      assert_instance_of Fixnum, count.value
      assert_equal dates.first, count.date_range.begin
      assert_equal dates.last, count.date_range.end
    end
  end

  def test_square_brackets
    VCR.use_cassette 'media_count/square_brackets' do
      dates = [DateTime.parse("1st March 2012"), DateTime.parse("5th May 2012")].map(&:to_time)
      count = Flickrie.get_media_counts(:taken_dates => dates.join(',')).first
      assert_equal '1', count['count']
    end
  end
end

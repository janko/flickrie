RSpec::Matchers.define :correspond_to do |hash_or_value|
  match { |object| test_recursively(object, hash_or_value) }

  def test_recursively(object, hash_or_value)
    if hash_or_value.is_a?(Hash)
      iterate(object, hash_or_value) do |actual, expected|
        actual.should == expected
      end
    else
      object.should eq(hash_or_value)
    end
  end

  def iterate(object, the_rest, &block)
    the_rest.each do |key, value|
      if value.is_a?(Hash)
        iterate(object.send(key), value, &block)
      else
        yield [object.send(key), value]
      end
    end
  end

  failure_message_for_should do |actual|
    "expected: #{expected.first}\n got: #{actual}\n"
  end
end

RSpec::Matchers.define :be_a_number do
  match { |object| object.instance_of?(Fixnum) }
end

RSpec::Matchers.define :be_a_boolean do
  match { |object| object == true or object == false }
end

RSpec::Matchers.define :be_a_media do
  match do |object|
    object.instance_of?(Flickrie::Photo) \
      or
    object.instance_of?(Flickrie::Video)
  end
end

RSpec::Matchers.define :be_a_photo do
  match { |object| object.instance_of?(Flickrie::Photo) }
end

RSpec::Matchers.define :be_a_video do
  match { |object| object.instance_of?(Flickrie::Video) }
end

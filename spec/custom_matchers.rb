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
end

RSpec::Matchers.define :be_a_boolean do
  match { |object| object == true or object == false }
end

module CustomMatchers
  extend RSpec::Matchers::DSL

  matcher :be_a_media do
    match do |object|
      object.instance_of?(Flickrie::Photo) \
        or
      object.instance_of?(Flickrie::Video)
    end
  end

  matcher :be_a_photo do
    match { |object| object.instance_of?(Flickrie::Photo) }
  end

  matcher :be_a_video do
    match { |object| object.instance_of?(Flickrie::Video) }
  end
end

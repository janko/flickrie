require 'spec_helper'

SIZES = ['Square 75', 'Thumbnail', 'Square 150', 'Small 240', 'Small 320',
  'Medium 500', 'Medium 640', 'Medium 800', 'Large 1024', 'Large 1600',
  'Large 2048']

describe Flickrie::Photo do
  def non_bang_sizes(photo)
    [
      photo.square(75), photo.square(150), photo.thumbnail,
      photo.small(240), photo.small(320), photo.medium(500),
      photo.medium(640), photo.medium(800), photo.large(1024),
      photo.large(1600), photo.large!(2048),
      photo.square75, photo.square150, photo.small240,
      photo.small320, photo.medium500, photo.medium640,
      photo.medium800, photo.large1024, photo.large1600,
      photo.large2048, photo.largest
    ]
  end

  def bang_sizes(photo)
    [
      proc { photo.square!(75) }, proc { photo.square!(150) },
      proc { photo.thumbnail! }, proc { photo.small!(240) },
      proc { photo.small!(320) }, proc { photo.medium!(500) },
      proc { photo.medium!(640) }, proc { photo.medium!(800) },
      proc { photo.large!(1024) }, proc { photo.large!(1600)},
      proc { photo.large!(2048) },
      proc { photo.square75! }, proc { photo.square150! },
      proc { photo.small240! }, proc { photo.small320! },
      proc { photo.medium500! }, proc { photo.medium640! },
      proc { photo.medium800! }, proc { photo.large1024! },
      proc { photo.large1600! }, proc { photo.large2048! },
      proc { photo.largest! }
    ]
  end

  def test_sizes(photo)
    non_bang_sizes(photo).each do |photo|
      [:size, :width, :height, :source_url].each do |attr|
        photo.send(attr).should_not be_nil
      end
    end

    bang_sizes(photo).each do |photo_proc|
      result_photo = photo_proc.call
      [:size, :width, :height, :source_url].each do |attr|
        photo.send(attr).should_not be_nil
      end
      [:size, :width, :height, :source_url].each do |attr|
        result_photo.send(attr).should_not be_nil
      end
    end
  end

  context "get sizes" do
    it "should have attributes correctly set", :vcr do
      [
        Flickrie.get_photo_sizes(PHOTO_ID),
        Flickrie::Photo.public_new('id' => PHOTO_ID).get_sizes
      ].
        each do |photo|
          [:can_download?, :can_blog?, :can_print?].each do |attribute|
            photo.send(attribute).should be_a_boolean
          end

          test_sizes(photo)
          photo.available_sizes.should eq(SIZES)
        end
    end
  end

  context "search" do
    it "should have all sizes available", :vcr do
      photo = Flickrie.search_photos(:user_id => USER_NSID, :extras => EXTRAS).
        find { |photo| photo.id == PHOTO_ID }
      photo.available_sizes.should eq(SIZES)
    end
  end

  context "get info" do
    it "should have all attributes correctly set", :vcr do
      photo = Flickrie.get_photo_info(PHOTO_ID)
      photo.rotation.should eq(90)
    end
  end

  context "blank photo" do
    it "should have all attributes equal to nil" do
      photo = Flickrie::Photo.public_new

      [:width, :height, :source_url, :rotation, :size].each do |attr|
        photo.send(attr).should be_nil
      end

      photo.available_sizes.should be_empty

      non_bang_sizes(photo).each do |photo|
        photo.source_url.should be_nil
        photo.width.should be_nil
        photo.height.should be_nil
      end

      bang_sizes(photo).each do |photo_proc|
        photo_proc.call
        photo.source_url.should be_nil
        photo.width.should be_nil
        photo.height.should be_nil
      end
    end
  end
end

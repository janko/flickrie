require 'spec_helper'

SIZES = ['Square 75', 'Thumbnail', 'Square 150', 'Small 240', 'Small 320',
  'Medium 500', 'Medium 640', 'Medium 800', 'Large 1024']

describe Flickrie::Photo do
  def test_sizes(photo)
    # TODO: simplify this
    # non-bang versions
    [
      [[photo.square(75), photo.square75],   ['Square 75', '75x75']],
      [[photo.thumbnail],                    ['Thumbnail', '75x100']],
      [[photo.square(150), photo.square150], ['Square 150', '150x150']],
      [[photo.small(240), photo.small240],   ['Small 240', '180x240']],
      [[photo.small(320), photo.small320],   ['Small 320', '240x320']],
      [[photo.medium(500), photo.medium500], ['Medium 500', '375x500']],
      [[photo.medium(640), photo.medium640], ['Medium 640', '480x640']],
      [[photo.medium(800), photo.medium800], ['Medium 800', '600x800']],
      [[photo.large(1024), photo.large1024], ['Large 1024', '768x1024']]
    ].
      each do |photos, expected_values|
        flickr_size, size = expected_values
        photos.each do |photo|
          photo.size.should eq(flickr_size)
          [photo.width, photo.height].join('x').should eq(size)
          photo.source_url.should_not be_empty
        end
      end

    # bang versions
    [
      [[proc { photo.square!(75) }, proc { photo.square75! }],   ['Square 75', '75x75']],
      [[proc { photo.thumbnail! }],                              ['Thumbnail', '75x100']],
      [[proc { photo.square!(150) }, proc { photo.square150! }], ['Square 150', '150x150']],
      [[proc { photo.small!(240) }, proc { photo.small240! }],   ['Small 240', '180x240']],
      [[proc { photo.small!(320) }, proc { photo.small320! }],   ['Small 320', '240x320']],
      [[proc { photo.medium!(500) }, proc { photo.medium500! }], ['Medium 500', '375x500']],
      [[proc { photo.medium!(640) }, proc { photo.medium640! }], ['Medium 640', '480x640']],
      [[proc { photo.medium!(800) }, proc { photo.medium800! }], ['Medium 800', '600x800']],
      [[proc { photo.large!(1024) }, proc { photo.large1024! }], ['Large 1024', '768x1024']]
    ].
      each do |blocks, expected_values|
        flickr_size, size = expected_values
        blocks.each do |block|
          result_photo = block.call
          [result_photo, photo].each do |photo|
            photo.size.should eq(flickr_size)
            [photo.width, photo.height].join('x').should eq(size)
            photo.source_url.should_not be_empty
          end
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
          photo.can_download?.should be_true
          photo.can_blog?.should be_false
          photo.can_print?.should be_false

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

  context "blank" do
    it "should have all attributes equal to nil" do
      photo = Flickrie::Photo.public_new

      photo.width.should be_nil
      photo.height.should be_nil
      photo.source_url.should be_nil
      photo.rotation.should be_nil
      photo.available_sizes.should be_empty
      photo.size.should be_nil

      [
        photo.square(75), photo.square(150), photo.thumbnail,
        photo.small(240), photo.small(320), photo.medium(500),
        photo.medium(640), photo.medium(800), photo.large(1024),
        photo.original, photo.square75, photo.square150,
        photo.small240, photo.small320, photo.medium500,
        photo.medium640, photo.medium800, photo.large1024,
        photo.largest
      ].
        each do |photo|
          photo.source_url.should be_nil
          photo.width.should be_nil
          photo.height.should be_nil
        end

      [
        proc { photo.square!(75) }, proc { photo.square!(150) },
        proc { photo.thumbnail! }, proc { photo.small!(240) },
        proc { photo.small!(320) }, proc { photo.medium!(500) },
        proc { photo.medium!(640) }, proc { photo.medium!(800) },
        proc { photo.large!(1024) }, proc { photo.original! },
        proc { photo.square75! }, proc { photo.square150! },
        proc { photo.small240! }, proc { photo.small320! },
        proc { photo.medium500! }, proc { photo.medium640! },
        proc { photo.medium800! }, proc { photo.large1024! },
        proc { photo.largest! }
      ].
        each do |prok|
          prok.call
          photo.source_url.should be_nil
          photo.width.should be_nil
          photo.height.should be_nil
        end
    end
  end
end

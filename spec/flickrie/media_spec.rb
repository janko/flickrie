require 'spec_helper'

describe :Media do
  before(:all) do
    @attributes = {
      id: PHOTO_ID,
      secret: '25bb44852b',
      server: '7049',
      farm: 8,
      title: 'IMG_0796',
      description: 'Test',
      media_status: 'ready',
      path_alias: nil,
      camera: 'Canon PowerShot G12',
      comments_count: 1,
      location: {
        latitude: 45.807258,
        longitude: 15.967599,
        accuracy: '11',
        context: 0,
        neighbourhood: nil,
        locality: {
          name: 'Zagreb',
          place_id: '00j4IylZV7scWik',
          woeid: '851128'
        },
        county: {
          name: 'Zagreb',
          place_id: '306dHrhQV7o6jm.ZUQ',
          woeid: '15022257'
        },
        region: {
          name: 'Grad Zagreb',
          place_id: 'Js1DU.pTUrpBCIKhVw',
          woeid: '20070170'
        },
        country: {
          name: 'Croatia',
          place_id: 'FunRCI5TUb6a6soTyw',
          woeid: '23424843'
        },
        place_id: '00j4IylZV7scWik',
        woeid: '851128'
      },
      geo_permissions: {
        :public? => true,
        :contacts? => false,
        :friends? => false,
        :family? => false
      },
      tags: {
        first: {
          content: 'luka',
          author: {
            nsid: USER_NSID
          },
          raw: 'luka',
          :machine_tag? => false
        }
      },
      machine_tags: [],
      license: {id: '0'},
      taken_at_granularity: 0,
      owner: {
        nsid: USER_NSID,
        username: USER_USERNAME,
        real_name: USER_USERNAME,
        location: "Zagreb, Croatia",
        icon_server: "5464",
        icon_farm: 6
      },

      safety_level: 0,
      :safe? => true,
      :moderate? => false,
      :restricted? => false,

      visibility: {
        :public? => true,
        :family? => false,
        :friends? => false,
        :contacts? => nil
      },
      :favorite? => false,

      :has_people? => false,
      notes: {
        first: {
          id: '72157629487842968',
          author: {
            nsid: USER_NSID,
            username: USER_USERNAME
          },
          coordinates: [316, 0],
          width: 59,
          height: 50,
          content: 'Test'
        }
      }
    }
  end

  context "get info", :vcr do
    let(:media) {
      [
        Flickrie.get_media_info(PHOTO_ID),
        Flickrie::Photo.public_new('id' => PHOTO_ID).get_info,
        Flickrie::Video.public_new('id' => PHOTO_ID).get_info
      ]
    }

    it "has correct attributes" do
      media.each do |media|
        [
          :id, :secret, :server, :farm, :title, :description,
          :comments_count, :location, :geo_permissions, :tags,
          :machine_tags, :license, :taken_at_granularity, :owner,
          :safety_level, :safe?, :moderate?, :restricted?, :visibility,
          :favorite?, :has_people?, :notes
        ].
          each do |attribute|
            media.send(attribute).should correspond_to(@attributes[attribute])
          end

        # can change, so just checking the type
        [
          :can_comment?, :can_add_meta?, :can_everyone_comment?,
          :can_everyone_add_meta?, :can_download?, :can_blog?,
          :can_print?, :can_share?
        ].
          each { |attribute| media.send(attribute).should be_a_boolean }

        media.views_count.should be_a(Fixnum)

        # time
        [:posted_at, :uploaded_at, :updated_at, :taken_at].each do |time_attribute|
          media.send(time_attribute).should be_an_instance_of(Time)
        end

        # other
        media.url.should_not be_empty
        media['id'].should eq(PHOTO_ID)
        media.hash['id'].should eq(PHOTO_ID)
      end
    end
  end

  context "extras", :vcr do
    let(:media) { Flickrie.media_from_set(SET_ID, extras: EXTRAS).first }

    it "has correct attributes" do
      complete = [:media_status, :geo_permissions, :machine_tags, :license, :taken_at_granularity]
      complete.each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end

      # the incomplete ones
      media.location.should correspond_to(@attributes[:location].except(:locality, :county, :region, :country))
      media.tags.first.should correspond_to(@attributes[:tags][:first].except(:author, :raw, :machine_tag?))
      media.owner.should correspond_to(@attributes[:owner].except(:real_name, :location))

      # time
      [:uploaded_at, :updated_at, :taken_at].each do |time_attribute|
        media.send(time_attribute).should be_an_instance_of(Time)
      end

      # other
      media.views_count.should be_a(Fixnum)
    end
  end

  context "from set", :vcr do
    let(:media) { Flickrie.media_from_set(SET_ID, extras: EXTRAS).find { |media| media.id == PHOTO_ID } }

    it "has correct attributes" do
      [:id, :secret, :server, :farm, :title].each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end
      media.primary?.should be_true
      media.url.should_not be_empty
      media.owner.nsid.should == USER_NSID
    end
  end

  context "from user", :vcr do
    let(:media) { Flickrie.media_from_user(USER_NSID, extras: EXTRAS).find { |media| media.id == PHOTO_ID } }

    it "has correct attributes" do
      [:id, :secret, :server, :farm, :title, :visibility].each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end
      media.owner.nsid.should == USER_NSID
    end
  end

  context "public from user", :vcr do
    let(:media) { Flickrie.public_media_from_user(USER_NSID, extras: EXTRAS).find { |media| media.id == PHOTO_ID } }

    it "has correct attributes" do
      [:id, :secret, :server, :farm, :title, :visibility].each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end
      media.owner.nsid.should == USER_NSID
    end
  end

  context "search", :vcr do
    let(:media) { Flickrie.search_media(user_id: USER_NSID, extras: EXTRAS).find { |media| media.id == PHOTO_ID } }

    it "has correct attributes" do
      [:id, :secret, :server, :farm, :title, :visibility].each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end
      media.owner.nsid.should == USER_NSID
    end
  end

  context "from contacts", :vcr do
    let(:media) {
      params = {include_self: 1, single_photo: 1}
      [
        Flickrie.media_from_contacts(params).first,
        Flickrie.public_media_from_user_contacts(USER_NSID, params).first
      ]
    }

    it "has correct attributes" do
      media.each do |media|
        attributes = {
          id: '7093101501',
          secret: '9337f28800',
          server: '7090',
          farm: 8,
          owner: {
            nsid: USER_NSID,
            username: USER_USERNAME
          },
          title: 'IMG_0917',
          visibility: {:public? => true},
          media_status: 'ready'
        }

        attributes.keys.each do |attribute|
          media.send(attribute).should correspond_to(attributes[attribute])
        end
      end
    end
  end

  context "get context", :vcr do
    let(:context) { Flickrie.get_media_context(PHOTO_ID) }

    it "has correct attributes" do
      context.count.should eq(98)

      attributes = {
        id: '6946978706',
        secret: 'b38270bbd6',
        server: '7216',
        farm: 8,
        title: 'IMG_0795',
        license: {id: '0'},
        :faved? => false
      }
      attributes.keys.each do |attribute|
        context.previous.send(attribute).should correspond_to(attributes[attribute])
      end
      context.previous.url.should_not be_empty
    end
  end

  context "get exif", :vcr do
    let(:media) {
      [
        Flickrie.get_photo_exif(PHOTO_ID),
        Flickrie::Photo.public_new('id' => PHOTO_ID).get_exif
      ]
    }

    it "has correct attributes" do
      media.each do |media|
        media.camera.should eq('Canon PowerShot G12')
        media.exif.get('X-Resolution').should eq('180 dpi')
        media.exif.get('X-Resolution', data: 'clean').should eq('180 dpi')
        media.exif.get('X-Resolution', data: 'raw').should eq('180')
      end
    end
  end

  context "get not in set", :vcr do
    let(:media) { Flickrie.media_not_in_set(extras: EXTRAS).first }

    it "has correct attributes", :vcr do
      [:id, :secret, :server, :farm, :title, :visibility].each do |attribute|
        media.send(attribute).should correspond_to(@attributes[attribute])
      end
      media.owner.nsid.should == USER_NSID
    end
  end

  context "get permissions", :vcr do
    let(:media) { Flickrie.get_photo_permissions(PHOTO_ID) }

    it "has correct attributes", :vcr do
      media.id.should == PHOTO_ID
      media.visibility.should correspond_to(@attributes[:visibility])
      media.commenting_permissions.should == 3
      media.adding_meta_permissions.should == 2
    end
  end

  it "has #short_url", :vcr do
    media = Flickrie.get_media_info(MEDIA_ID)
    connection = Faraday.new(media.short_url) do |b|
      b.use FaradayMiddleware::FollowRedirects, limit: 5
      b.adapter :net_http
    end
    response = connection.get
    response.status.should == 200
  end

  context "get set context", :vcr do
    it "has correct attributes" do
      context = Flickrie.get_set_context(SET_ID, MEDIA_ID)
      context.previous.should be_nil
      context.next.should be_a(Flickrie::Photo)
    end
  end

  context "blank media" do
    let(:media) { Flickrie::Photo.public_new({}) }

    it "has attributes equal to nil" do
      attributes = Flickrie::Media.instance_methods -
        Object.instance_methods -
        [:[], :get_info, :get_exif, :get_favorites, :to_base58]

      attributes.each do |attribute|
        media.send(attribute).should be_nil
      end
    end
  end
end

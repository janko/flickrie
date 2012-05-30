require 'spec_helper'

describe Flickrie::Collection do
  let(:photos) { Flickrie.photos_from_set(SET_ID, :per_page => 8, :page => 1) }
  let(:photo_id) { '6946978706' }

  context "without will_paginate", :vcr do
    it "has the correct pagination attributes" do
      photos.current_page.should == 1
      photos.per_page.should == 8
      photos.total_entries.should == 97
      photos.total_pages.should == 13
    end

    it "can find by id" do
      photo = photos.find(photo_id.to_i)
      photo.id.should == photo_id
    end

    it "can find normally" do
      photo = photos.find { |photo| photo.id == photo_id }
      photo.id.should == photo_id
    end
  end

  context "with will_paginate", :vcr do
    before(:all) do
      Flickrie.pagination = :will_paginate

      # This 'unloads' Flickrie::Collection, than loads it back on
      # (because now Flickrie.pagination is set)
      module Flickrie; remove_const :Collection end
      load "flickrie/collection.rb"
    end

    it "has the correct pagination attributes" do
      photos.current_page.should == 1
      photos.per_page.should == 8
      photos.total_entries.should == 97
      photos.total_pages.should == 13
    end

    it "has the additional 'will_paginate' attributes" do
      photos.offset.should == 0
      photos.out_of_bounds?.should be_false
    end

    it "can find by id" do
      photo = photos.find(photo_id.to_i)
      photo.id.should == photo_id
    end

    it "can find normally" do
      photo = photos.find { |photo| photo.id == photo_id }
      photo.id.should == photo_id
    end
  end
end

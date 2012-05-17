require 'spec_helper'

describe Flickrie::Location do
  context "blank" do
    it "should have all attributes equal to nil" do
      location = Flickrie::Location.public_new
      attributes = location.methods - Object.instance_methods - [:[]]
      attributes.each do |attribute|
        location.send(attribute).should be_nil
      end
    end
  end

  context "accessing areas" do
    it "should have #to_s defined on them" do
      location = Flickrie::Location.public_new \
        'neighbourhood' => {
          '_content' => 'A gangsta ghetto, yo'
        }

      location.neighbourhood.to_s.should eq('A gangsta ghetto, yo')
    end
  end
end

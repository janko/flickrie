require 'spec_helper'

describe :Location do
  context "blank" do
    let(:location) { Flickrie::Location.public_new }

    it "has all attributes equal to nil" do
      attributes = location.methods - Object.instance_methods - [:[]]
      attributes.each do |attribute|
        location.send(attribute).should be_nil
      end
    end
  end

  context "accessing areas" do
    it "has #to_s defined on them" do
      location = Flickrie::Location.public_new \
        'neighbourhood' => {
          '_content' => 'A gangsta ghetto, yo'
        }

      location.neighbourhood.to_s.should eq('A gangsta ghetto, yo')
    end
  end
end

require 'spec_helper'

describe :License do
  context "get" do
    let(:licenses) { Flickrie.get_licenses }

    it "has correct attributes", :vcr do
      licenses.each do |license|
        ('0'..'8').should cover(license.id)
        license.name.should be_an_instance_of(String)
        license.url.should be_an_instance_of(String)
      end
    end
  end
end

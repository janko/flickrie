require 'spec_helper'

describe Flickrie::License do
  context "get" do
    it "should have all attributes correctly set", :vcr do
      licenses = Flickrie.get_licenses

      licenses.each do |license|
        ('0'..'8').should cover(license.id)
        license.name.should be_an_instance_of(String)
        license.url.should be_an_instance_of(String)
      end
    end
  end
end

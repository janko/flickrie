describe Flickrie::License do
  context "get licenses" do
    use_vcr_cassette "license/get"

    it "should have all attributes correctly set" do
      licenses = Flickrie.get_licenses

      licenses.each do |license|
        ('0'..'8').should cover(license.id)
        license.name.should be_an_instance_of(String)
        license.url.should be_an_instance_of(String)
      end
    end
  end
end

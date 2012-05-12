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
end

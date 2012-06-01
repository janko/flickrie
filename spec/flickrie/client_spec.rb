require 'spec_helper'

describe :Client do
  it "recognizes the `:include_sizes` option", :vcr do
    response = Flickrie.client.media_from_set(SET_ID)
    response.body['photoset']['photo'].first.should_not have_key('url_s')

    response = Flickrie.client.media_from_set(SET_ID, :include_sizes => true)
    response.body['photoset']['photo'].first.should have_key('url_s')
  end
end

require 'test/unit'
require 'flickrie'

Flickrie.api_key = ENV['FLICKR_API_KEY']
Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']
Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end

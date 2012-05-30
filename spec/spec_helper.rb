# encoding: utf-8
require 'flickrie'
require 'vcr'
require 'custom_matchers'

RSpec.configure do |c|
  c.before(:all) do
    Flickrie.api_key = ENV['FLICKR_API_KEY']
    Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
    Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']
    Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']
  end
  c.treat_symbols_as_metadata_keys_with_true_values = true # For VCR
  c.fail_fast = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = {
    :record => :new_episodes, # Records new HTTP requests if any.
    :serialize_with => :syck, # Don't output in binary form (only in Ruby 1.9.3-p125).
    :match_requests_on => [
      :method,
      VCR.request_matchers.uri_without_param(:api_key) # Don't require the API key.
    ]
  }
  c.filter_sensitive_data('API_KEY')      { ENV['FLICKR_API_KEY'] }
  c.filter_sensitive_data('ACCESS_TOKEN') { ENV['FLICKR_ACCESS_TOKEN'] }
  c.configure_rspec_metadata! # Enables tagging RSpec examples with `:vcr`.
end

PHOTO_PATH = File.expand_path('../files/photo.jpg', __FILE__).freeze
MEDIA_ID = '6946979188'.freeze
PHOTO_ID = '6946979188'.freeze
VIDEO_ID = '7093038981'.freeze
SET_ID = '72157629851991663'.freeze
USER_NSID = '67131352@N04'.freeze
USER_USERNAME = 'Janko Marohnić'.freeze
USER_EMAIL = 'janko.marohnic@gmail.com'.freeze
EXTRAS = 'license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_h,url_k,url_o'.freeze

# The `#initialize` methods are private, so this creates a public version.
klasses = [Flickrie::Set, Flickrie::Photo, Flickrie::Video, Flickrie::Location, Flickrie::User]
klasses.each do |klass|
  klass.instance_eval do
    def public_new(*args)
      new(*args)
    end
  end
end

require 'flickrie'
require 'vcr'
require 'active_support/core_ext/hash/except'
begin
  require 'debugger'
rescue LoadError
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :faraday
  config.default_cassette_options = {
    :record => :new_episodes,
    :serialize_with => :syck,
    :match_requests_on => [:method, VCR.request_matchers.uri_without_param(:api_key)]
  }
  config.filter_sensitive_data('API_KEY') { ENV['FLICKR_API_KEY'] }
  config.filter_sensitive_data('ACCESS_TOKEN') { ENV['FLICKR_ACCESS_TOKEN'] }
end

module RSpecHelpers
  def test_attribute(object, attribute, hash = nil)
    expectation = hash || @attributes[attribute]
    unless expectation.is_a?(Hash)
      object.send(attribute).should eq(expectation)
    else
      iterate(object.send(attribute), expectation) do |actual, expected|
        actual.should eq(expected)
      end
    end
  end

  def iterate(object, rest, &block)
    rest.each do |key, value|
      if value.is_a?(Hash)
        iterate(object.send(key), value, &block)
      else
        yield [object.send(key), value]
      end
    end
  end
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  config.include RSpecHelpers
  config.before(:all) do
    Flickrie.api_key = ENV['FLICKR_API_KEY']
    Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
    # so that I can use the '@instance' object when I want to make authenticated API calls
    @flickrie = Flickrie::Instance.new(ENV['FLICKR_ACCESS_TOKEN'], ENV['FLICKR_ACCESS_SECRET'])
  end
end

PHOTO_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'files/photo.jpg').freeze
PHOTO_ID = '6946979188'.freeze
VIDEO_ID = '7093038981'.freeze
SET_ID = '72157629851991663'.freeze
USER_NSID = '67131352@N04'.freeze
EXTRAS = %w[license date_upload date_taken owner_name
  icon_server original_format last_update geo tags machine_tags
  o_dims views media path_alias url_sq url_q url_t url_s url_n
  url_m url_z url_c url_l url_o].join(',').freeze
# for copying:
#   license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o

klasses = [Flickrie::Set, Flickrie::Photo, Flickrie::Video, Flickrie::User, Flickrie::Location]
klasses.each do |klass|
  klass.instance_eval do
    def public_new(*args)
      new(*args)
    end
  end
end

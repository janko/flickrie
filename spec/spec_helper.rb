# encoding: utf-8
require 'flickrie'
require 'vcr'
begin
  require 'debugger'
rescue LoadError
end
require 'custom_matchers'

module RSpecHelpers
  def test_recursively(object, attribute, hash = nil)
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

RSpec.configure do |c|
  c.include RSpecHelpers
  c.include CustomMatchers
  c.before(:all) do
    Flickrie.api_key = ENV['FLICKR_API_KEY']
    Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
    Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']
    Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']
  end
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.around(:each, :vcr) do |example|
    # This is just an automatization of naming the VCR cassettes
    klass = example.metadata[:example_group][:example_group][:description_args].first
    folder = klass.to_s.split('::').last.split(/(?=[A-Z])/).map(&:downcase).join('_')
    subfolder = example.metadata[:example_group][:description_args].first
    cassette_name = example.metadata[:description_args].first.match(/^should /).post_match
    VCR.use_cassette("#{folder}/#{subfolder}/#{cassette_name}") { example.call }
  end
  c.fail_fast = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = {
    :record => :new_episodes,
    :serialize_with => :syck,
    :match_requests_on => [:method, VCR.request_matchers.uri_without_param(:api_key)]
  }
  c.filter_sensitive_data('API_KEY') { ENV['FLICKR_API_KEY'] }
  c.filter_sensitive_data('ACCESS_TOKEN') { ENV['FLICKR_ACCESS_TOKEN'] }
end

PHOTO_PATH = File.expand_path('../files/photo.jpg', __FILE__).freeze
MEDIA_ID = '6946979188'.freeze
PHOTO_ID = '6946979188'.freeze
VIDEO_ID = '7093038981'.freeze
SET_ID = '72157629851991663'.freeze
USER_NSID = '67131352@N04'.freeze
USER_USERNAME = 'Janko Marohnić'.freeze
USER_EMAIL = 'janko.marohnic@gmail.com'.freeze
EXTRAS = %w[license date_upload date_taken owner_name
  icon_server original_format last_update geo tags machine_tags
  o_dims views media path_alias url_sq url_q url_t url_s url_n
  url_m url_z url_c url_l url_o].join(',').freeze
# for copying:
#   license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media,path_alias,url_sq,url_q,url_t,url_s,url_n,url_m,url_z,url_c,url_l,url_o

klasses = [Flickrie::Set, Flickrie::Photo, Flickrie::Video, Flickrie::Location]
klasses.each do |klass|
  klass.instance_eval do
    def public_new(*args)
      new(*args)
    end
  end
end

class Hash
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def except(*keys)
    self.dup.except!(*keys)
  end
end

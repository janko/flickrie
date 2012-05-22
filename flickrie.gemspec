# encoding: utf-8
require File.expand_path("../lib/flickrie/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name         = "flickrie"
  gem.version      = Flickrie::VERSION

  gem.author       = "Janko Marohnić"
  gem.email        = "janko.marohnic@gmail.com"
  gem.description  = %q{This gem wraps the Flickr API with a nice object-oriented interface.}
  gem.summary      = gem.description
  gem.homepage     = "https://github.com/janko-m/flickrie"

  gem.files        = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  gem.require_path = "lib"
  gem.test_files   = gem.files.grep(%r{^(test|spec|features)/})

  gem.license      = "MIT"

  gem.required_ruby_version = ">= 1.9.2"

  gem.add_dependency "faraday_middleware", '>= 0.8.7', '< 0.9'
  gem.add_dependency "faraday", '>= 0.7.6', '< 0.9'
  gem.add_dependency "simple_oauth", '~> 0.1'
  gem.add_dependency "multi_xml", '~> 0.4'

  gem.add_development_dependency "bundler", '~> 1.0'
  gem.add_development_dependency "rake", '~> 0.9'
  gem.add_development_dependency "rspec", '>= 2.10', '< 3'
  gem.add_development_dependency "vcr", '~> 2.1'
end

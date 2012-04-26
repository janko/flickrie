# encoding: utf-8
require File.expand_path('../lib/flickrie/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Janko Marohnić"]
  gem.email         = ["janko.marohnic@gmail.com"]
  gem.description   = %q{This gem is a nice wrapper for the Flickr API with an intuitive interface.}
  gem.summary       = %q{The reason why I did this gem is because the other ones either weren't well maintained, or they were too literal in the sense that the response from the API call wasn't processed almost at all. It doesn't seem too bad at first, but after a while you realize it's not pretty. So I wanted to make it pretty :)}
  gem.homepage      = "https://github.com/janko-m/flickrie"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "flickrie"
  gem.require_paths = ["lib"]
  gem.version       = Flickrie::VERSION

  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'simple_oauth'
end

# encoding: utf-8
Gem::Specification.new do |gem|
  gem.required_ruby_version = ">= 1.9.0"

  gem.version       = "0.7.1"

  gem.author        = "Janko Marohnić"
  gem.email         = "janko.marohnic@gmail.com"
  gem.description   = %q{This gem is a nice wrapper for the Flickr API with an intuitive interface.}
  gem.summary       = %q{The reason why I did this gem is because the other ones either weren't well maintained, or they were too literal in the sense that the response from the API call wasn't processed almost at all. It doesn't seem too bad at first, but after a while you realize it's not pretty. So I wanted to make it pretty :)}
  gem.homepage      = "https://github.com/janko-m/flickrie"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "flickrie"
  gem.require_paths = ["lib"]
  gem.version       = Flickrie::VERSION

  gem.license       = "MIT"

  gem.add_dependency "faraday_middleware"
  gem.add_dependency "simple_oauth", '~> 0.1'
  gem.add_dependency "multi_xml", '~> 0.4'

  gem.add_development_dependency "activesupport", '>= 3'
  gem.add_development_dependency "rspec", '>= 2'
  gem.add_development_dependency "vcr"
end

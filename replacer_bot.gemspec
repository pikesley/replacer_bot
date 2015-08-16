# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'replacer_bot/version'

Gem::Specification.new do |spec|
  spec.name          = 'replacer_bot'
  spec.version       = ReplacerBot::VERSION
  spec.authors       = ['pikesley']
  spec.email         = ['github@orgraphone.org']
  spec.summary       = %q{Search, mangle and tweet}
  spec.description   = %q{Search Twitter for a phrase, search-and-replace phrases in the tweets, tweet them}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'twitter', '~> 5.14'
  spec.add_dependency 'dotenv', '~> 2.0'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'guard-rspec', '~> 4.6'
  spec.add_development_dependency 'guard-cucumber', '~> 1.6'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.21'
  spec.add_development_dependency 'cucumber' , '~> 2.0'
  spec.add_development_dependency 'aruba', '~> 0.8'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end

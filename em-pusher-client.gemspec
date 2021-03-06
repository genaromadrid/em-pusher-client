# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'em/pusher/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'em-pusher-client'
  spec.version       = Em::Pusher::Client::VERSION
  spec.authors       = ['Genaro Madrid']
  spec.email         = ['genmadrid@gmail.com']

  spec.summary       = 'Eventmachine pusher.com client'
  spec.description   = 'Subscribe to channels with eventmachine'
  spec.homepage      = 'https://github.com/genaromadrid/em-pusher-client'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine', '~> 1.2.5'
  spec.add_dependency 'websocket', '~> 1.2.5'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls', '0.8.21'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.54'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.24'
  spec.add_development_dependency 'simplecov', '~> 0.14'
end

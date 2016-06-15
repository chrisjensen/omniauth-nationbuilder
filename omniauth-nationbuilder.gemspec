# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-nationbuilder/version'

Gem::Specification.new do |gem|
  gem.name          = "omniauth-nationbuilder"
  gem.version       = Omniauth::Nationbuilder::VERSION
  gem.authors       = ["Chris Jensen"]
  gem.email         = ["chris@broadthought.co"]
  gem.description   = %q{Omniauth strategy for NationBuilder using OAuth2}
  gem.summary       = %q{Omniauth strategy for NationBuilder using OAuth2}
  gem.homepage      = "https://github.com/chrisjensen/omniauth-nationbuilder"
  gem.licenses      = ['MIT']
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'omniauth', '~> 1.1', '>= 1.1.1'
  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.3', '>= 1.3.1'

  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'rake'

  gem.add_development_dependency 'rack-test', '~> 0.5'
  gem.add_development_dependency 'webmock', '~> 1.7'
end

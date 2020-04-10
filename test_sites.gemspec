# frozen_string_literal: true

require File.expand_path('lib/test_sites/version', __dir__)

Gem::Specification.new do |s|
  s.name    = 'test_sites'
  s.version = test_sites::VERSION

  s.required_ruby_version = '>= 2.6.3'

  s.authors = ['Neil Berkman']
  s.email = ['neil@berkman.com']
  s.summary = 'COVID-19 Test Site Data'
  s.description = s.summary
  s.licenses = ['MIT']

  s.executables   = ['test_sites']
  s.require_paths = ['lib']
  s.files         = `git ls-files bin lib *.md LICENSE`.split("\n")
end

# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'activesupport', '~> 6.0', '>= 6.0.2.2'
gem 'faraday', '~> 1.0', '>= 1.0.1'
gem 'geocoder', '~> 1.3', '>= 1.3.7'
gem 'google_maps_service', '~> 0.4.2'
gem 'hashie', '~> 3.4', '>= 3.4.4'
gem 'jaro_winkler', '~> 1.4'
gem 'json', '~> 2.3'
gem 'redis', '~> 4.1', '>= 4.1.3'
gem 'StreetAddress', '~> 1.0', '>= 1.0.6', require: 'street_address'
gem 'xsv', '~> 0.3.11'

group :development do
  gem 'rubocop'
end

group :development, :test do
  gem 'rake', '~> 13.0', '>= 13.0.1'
  gem 'test-unit', '~> 3.3', '>= 3.3.5'
end

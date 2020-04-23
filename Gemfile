# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'activemodel', '~> 6.0'
gem 'activesupport', '~> 6.0', '>= 6.0.2.2'
gem 'faraday', '~> 1.0', '>= 1.0.1'
gem 'faraday_middleware', '~> 1.0'
gem 'geocoder', '~> 1.3', '>= 1.3.7'
gem 'geodesics', '~> 1.0'
gem 'geoservices', git: 'https://github.com/Spark-Bio/geoservices-ruby.git',
                   ref: 'fe2d2c', require: 'geoservices'
gem 'google_maps_service', '~> 0.4.2'
gem 'hashie', '~> 3.4', '>= 3.4.4'
gem 'jaro_winkler', '~> 1.4'
gem 'json', '~> 2.3'
gem 'redis', '~> 4.1', '>= 4.1.3'
gem 'StreetAddress', '~> 1.0', '>= 1.0.6', require: 'street_address'
gem 'xsv', '~> 0.3.11'

group :development do
  gem 'pry'
  gem 'rubocop'
end

group :development, :test do
  gem 'faraday-detailed_logger', '~> 2.3'
  gem 'minitest', '~> 5.14'
  gem 'rake', '~> 13.0', '>= 13.0.1'
end

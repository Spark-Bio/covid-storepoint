# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'test_sites/data_file.rb'
require 'test_sites/geocoder_client.rb'
require 'test_sites/geocoder_result.rb'
require 'test_sites/hour_specifier.rb'
require 'test_sites/hour_parser.rb'
require 'test_sites/listings.rb'
require 'test_sites/listing.rb'
require 'test_sites/store_point.rb'
require 'test_sites/geocoder_results.rb'
require 'test_sites/geocoder.rb'

module TestSites
  VERSION = '0.1.0'
end

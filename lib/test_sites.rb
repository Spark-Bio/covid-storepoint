# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'test_sites/data_file'
require 'test_sites/geocoder_client'
require 'test_sites/geocoder_result'
require 'test_sites/hour_specifier'
require 'test_sites/source_entry'
require 'test_sites/source'
require 'test_sites/hour_parser'
require 'test_sites/listings'
require 'test_sites/listing'
require 'test_sites/store_point'
require 'test_sites/geocoder_results'
require 'test_sites/geocoder'

module TestSites
  VERSION = '0.1.0'
end

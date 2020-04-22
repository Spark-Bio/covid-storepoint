# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'logger'
require 'test_sites/api_client'
require 'test_sites/cac_client'
require 'test_sites/cac'
require 'test_sites/componentized_us_address'
require 'test_sites/data_file'
require 'test_sites/geocoder_client'
require 'test_sites/geocoder_result'
require 'test_sites/hour_specifier'
require 'test_sites/no_warning_mash'
require 'test_sites/source_entry'
require 'test_sites/source'
require 'test_sites/hour_parser'
require 'test_sites/listings'
require 'test_sites/listing'
require 'test_sites/store_point'
require 'test_sites/geocoder_results'
require 'test_sites/geocoder'
require 'test_sites/source_diff'

# Namespace for Spark Bio's test sites.
module TestSites
  VERSION ||= '0.1.0'

  def self.logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = ENV['LOG_LEVEL'].blank? ? Logger::ERROR : ENV['LOG_LEVEL']
    @logger
  end
end

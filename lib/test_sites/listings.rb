# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class Listings
    SOURCE_FILE = DataFile.path('current_source.csv')
    ADDRESS_KEY = 'Testing Site Address'

    def listings
      raw_listings_with_geocoding.map do |raw_listing|
        Listing.new(raw_listing, geocoder_result_for_raw_listing(raw_listing))
      end
    end

    def raw_listings_with_geocoding
      raw_listings_with_addresses.filter do |raw_listing|
        geocoder_result_for_raw_listing(raw_listing)
      end
    end

    def geocoder_result_for_raw_listing(raw_listing)
      address = raw_listing[ADDRESS_KEY]
      geocoder_results.filtered[address]
    end

    def raw_listings_with_addresses
      source.find_all do |raw_listing|
        address = raw_listing[ADDRESS_KEY]
        geocoder_results.filtered[address]
      end
    end

    def dup_addresses_in_original
      original_addrs = original.map { |listing| listing[ADDRESS_KEY] }
      original_addrs.find_all { |addr| original_addrs.count(addr) > 1 }
    end

    def source
      @source ||= CSV.read(SOURCE_FILE, headers: true, skip_blanks: true)
    end

    def geocoder_results
      @geocoder_results ||= GeocoderResults.new
    end

    def all_hours
      source.map { |row| row['Testing Site Hours'] }.compact.sort.uniq
    end
  end
end

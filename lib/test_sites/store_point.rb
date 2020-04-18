# frozen_string_literal: true

require 'csv'

module TestSites
  # Utility for formatting location data for Storepoint.
  class StorePoint
    HEADERS = %w[name description address city state postcode country phone
                 website email monday tuesday wednesday thursday friday saturday
                 sunday tags extra lat lng hours].freeze
    OUTPUT_FILE = DataFile.path('store_point.csv')

    attr_reader :debug

    def self.local_data
      CSV.read('test/fixtures/store_point.csv', headers: true)
    end

    def update
      seen = Set.new
      CSV.open(OUTPUT_FILE, 'w', write_headers: true,
                                 headers: HEADERS.join(',')) do |csv|
        listings.each do |listing|
          next if seen.member?(listing.raw_address)

          seen << listing.raw_address
          csv << headers.map { |header| listing.send(header) }
        end
      end

      true
    end

    def headers
      @headers ||= HEADERS
    end

    def listings
      @listings ||= Listings.new.listings
    end
  end
end

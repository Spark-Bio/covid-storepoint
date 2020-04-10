# frozen_string_literal: true

require 'csv'

module TestSites
  class StorePoint
    HEADERS = 'name,description,address,city,state,postcode,country,phone,website,email,monday,tuesday,wednesday,thursday,friday,saturday,sunday,tags,extra,lat,lng,hours'
    OUTPUT_FILE = DataFile.new('store_point.csv').to_s

    attr_reader :debug

    def update(debug: false)
      @debug = debug
      seen = Set.new
      CSV.open(OUTPUT_FILE,
               'w',
               write_headers: true,
               headers: HEADERS) do |csv|
        listings.each do |listing|
          next if seen.member?(listing.raw_address)

          seen << listing.raw_address
          puts "processing #{listing.raw_address}" if debug

          csv << headers.map { |header| listing.send(header) }
        end
      end

      true
    end

    def headers
      @headers ||= HEADERS.split(',')
    end

    def listings
      @listings ||= Listings.new.listings
    end
  end
end

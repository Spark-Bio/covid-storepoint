# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class Geocoder
    def process
      results = geocode
      geocoder_results.update(results)
    end

    def geocode
      puts "*** Geocoding #{non_empty_raw_listings.size} listings"

      counters = { skipped: 0, successes: 0, exceptions: 0 }
      non_empty_raw_listings.each_with_object({ successes: {}, exceptions: {} }) do |raw_listing, acc|
        address = raw_listing['Testing Site Address']
        next unless address

        if geocoder_results.already_geocoded?(address)
          counters[:skipped] += 1
          next
        end

        begin
          puts "geocoding #{address}"
          acc[:successes][address] = geocode_address(address)
          counters[:successes] += 1
        rescue StandardError => e
          puts "*** EXCEPTION for #{address}"
          acc[:exceptions][address] = { class: e.class.to_s, message: e.message }
          counters[:exceptions] += 1
        end

        puts "*** Successes: #{counters[:successes]}, Exceptions: #{counters[:exceptions]}, Skipped: #{counters[:exceptions]}"
      end
    end

    def non_empty_raw_listings
      listings.source.filter(&:any?)
    end

    def geocoder
      @geocoder ||= GeocoderClient.new
    end

    def geocode_address(address)
      geocoder.search(address)
    end

    def listings
      @listings ||= TestSites::Listings.new
    end

    def geocoder_results
      @geocoder_results ||= TestSites::GeocoderResults.new
    end
  end
end

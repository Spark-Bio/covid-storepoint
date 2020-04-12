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
      puts "*** Geocoding #{source.size} listings"

      counters = Struct.new(:skipped, :successes, :exceptions).new(0, 0, 0)
      source.each_with_object({ successes: {}, exceptions: {} }) do |source_entry, acc|
        if source_entry.address.nil? ||
           geocoder_results.already_geocoded?(source_entry.address)
          next
        end

        begin
          puts "geocoding #{source_entry.address}"
          acc[:successes][source_entry.address] = geocode_address(source_entry.address)
          counters.successes += 1
        rescue StandardError => e
          puts "*** EXCEPTION for #{source_entry.address}"
          acc[:exceptions][source_entry.address] = { class: e.class.to_s, message: e.message }
          counters.excpetions += 1
        end
      end.tap do
        puts '*** Gecoder Results'
        puts "    Successes: #{counters.successes}, Exceptions: #{counters.exceptions}, Skipped: #{counters.skipped}"
      end
    end

    def geocoder
      @geocoder ||= GeocoderClient.new
    end

    def geocode_address(address)
      geocoder.search(address)
    end

    def source
      @source ||= TestSites::Source.new
    end

    def geocoder_results
      @geocoder_results ||= TestSites::GeocoderResults.new
    end
  end
end

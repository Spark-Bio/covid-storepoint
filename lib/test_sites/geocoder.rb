# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  # Utility class for geocoding location data.
  class Geocoder
    def process
      results = geocode
      geocoder_results.update(results)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def geocode
      puts "*** Geocoding #{source.size} listings"

      counters = Struct.new(:skipped, :successes, :exceptions).new(0, 0, 0)
      # rubocop:disable Style/MultilineBlockChain
      source.each_with_object({ successes: {}, exceptions: {} }) do |entry, acc|
        if entry.address.nil? ||
           geocoder_results.already_geocoded?(entry.address)
          next
        end

        begin
          puts "geocoding #{entry.address}"
          acc[:successes][entry.address] = geocode_address(entry.address)
          counters.successes += 1
        rescue StandardError => e
          puts "*** EXCEPTION for #{entry.address}"
          acc[:exceptions][entry.address] = { class: e.class.to_s,
                                              message: e.message }
          counters.excpetions += 1
        end
      end.tap do
        puts '*** Gecoder Results'
        puts "    Successes: #{counters.successes}, Exceptions: "\
             "#{counters.exceptions}, Skipped: #{counters.skipped}"
      end
      # rubocop:enable Style/MultilineBlockChain
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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

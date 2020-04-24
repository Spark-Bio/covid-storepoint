# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  # Utility class for geocoding location data.
  class Geocoder
    def process(locations)
      results = geocode(locations)
      geocoder_results.update(results)
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def geocode(locations)
      TestSites.logger.debug "*** Geocoding #{locations.size} listings"

      counters = Struct.new(:skipped, :successes, :exceptions).new(0, 0, 0)
      # rubocop:disable Style/MultilineBlockChain
      locations.each_with_object({ successes: {}, exceptions: {} }) do |e, a|
        next if e.address.nil? || geocoder_results.already_geocoded?(e.address)

        begin
          TestSites.logger.debug "geocoding #{e.address}"
          a[:successes][e.address] = geocode_address(e.address)
          counters.successes += 1
        rescue StandardError => e
          TestSites.logger.debug "*** EXCEPTION for #{e.address}"
          a[:exceptions][e.address] = { class: e.class.to_s,
                                        message: e.message }
          counters.excpetions += 1
        end
      end.tap do
        TestSites.logger.debug '*** Gecoder Results'
        TestSites.logger
                 .debug "    Successes: #{counters.successes}, Exceptions: "\
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

    def geocoder_results
      @geocoder_results ||= TestSites::GeocoderResults.new
    end
  end
end

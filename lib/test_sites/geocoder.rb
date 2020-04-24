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
      locations.each_with_object({ successes: {}, exceptions: {} }) do |l, a|
        next if l.address.nil? || geocoder_results.already_geocoded?(l.address)

        begin
          TestSites.logger.debug "geocoding #{l.address}"
          a[:successes][l.address] = geocode_address(l.address)
          counters.successes += 1
        rescue StandardError => e
          TestSites.logger.debug "*** EXCEPTION for #{l.address}"
          a[:exceptions][l.address] = { class: e.class.to_s,
                                        message: e.message }
          counters.exceptions += 1
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

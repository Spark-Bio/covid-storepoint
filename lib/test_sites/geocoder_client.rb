# frozen_string_literal: true

require 'google_maps_service'
require 'geocoder'
require 'redis'

module TestSites
  # Wrapper for geocoder API.
  class GeocoderClient
    GOOGLE_API_KEY_COVID = ENV['GOOGLE_API_KEY_COVID']

    def search(address)
      gmaps.geocode(address)
    end

    def gmaps
      @gmaps ||= GoogleMapsService::Client.new(key: GOOGLE_API_KEY_COVID)
    end
  end
end

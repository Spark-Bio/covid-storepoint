# frozen_string_literal: true

require 'geoservices'
require 'singleton'

# Client for: https://covidtracking.com/api
module TestSites
  # Wraps the ArcGIS World Geocoding Service.
  # See https://developers.arcgis.com/labs/rest/find-places/.
  class ArcGISClient
    include Singleton

    # rubocop:disable Style/ClassVars
    @@connection = nil

    # Returns all results from the ArcGIS API.
    #
    # @param options [Hash] query parameters (ignored!)
    # @return [Hash] all ArcGIS results
    def self.all(options = {})
      ArcGISClient.connection.query(0, options)
    end

    def self.connection
      @@connection || ArcGISClient.instance
      @@connection
    end

    # Returns all locations from the ArcGIS API.
    #
    # @param options [Hash] query parameters (ignored!)
    # @return [Hash] keyed by ArcGIS ID, values contain attributes for the
    # location.
    def self.locations(options = {})
      all(options)['features'].each_with_object({}) do |arcgis_location, acc|
        mash = NoWarningMash.new(arcgis_location['attributes'])
        acc[mash.GlobalID] = mash
      end
    end

    def initialize
      @@connection = Geoservice::MapService.new(url:
        'https://services.arcgis.com/8ZpVMShClf8U8dae/ArcGIS/rest/services/'\
        'TestingLocations_public/FeatureServer'.dup)
      # rubocop:enable Style/ClassVars
    end
  end
end

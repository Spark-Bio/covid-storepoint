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

    def self.all(options = {})
      ArcGISClient.connection.query(0, options)
    end

    def self.connection
      @@connection || ArcGISClient.instance
      @@connection
    end

    def self.first_location(options = {})
      locations(options).first
    end

    def self.locations(options = {})
      all(options)['features']
    end

    def initialize
      @@connection = Geoservice::MapService.new(url:
        'https://services.arcgis.com/8ZpVMShClf8U8dae/ArcGIS/rest/services/'\
        'TestingLocations_public/FeatureServer'.dup)
      # rubocop:enable Style/ClassVars
    end
  end
end

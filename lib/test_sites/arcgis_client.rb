# frozen_string_literal: true

require 'geoservices'

# Client for: https://covidtracking.com/api
module TestSites
  # Wraps the ArcGIS World Geocoding Service.
  # See https://developers.arcgis.com/labs/rest/find-places/.
  class ArcGISClient
    def initialize
      @connection = Geoservice::MapService.new(url:
        'https://services.arcgis.com/8ZpVMShClf8U8dae/ArcGIS/rest/services/'\
        'TestingLocations_public/FeatureServer'.dup)
    end

    def all
      connection.query(0)['features']
    end

    private

    def connection
      @connection || ArcGISClient.new
      @connection
    end
  end
end

# frozen_string_literal: true

# Client for: https://covidtracking.com/api
class ArcGISClient

  def initialize
    @connection = Geoservice::MapService.new(url:
      'https://services.arcgis.com/8ZpVMShClf8U8dae/ArcGIS/rest/services/'\
      'TestingLocations_public/FeatureServer')
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

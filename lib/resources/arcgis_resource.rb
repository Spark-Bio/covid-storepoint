# frozen_string_literal: true

require 'active_resource'

# Wraps the ArcGIS World Geocoding Service.
# See https://developers.arcgis.com/labs/rest/find-places/.
class ArcGISResource < ActiveResource::Base
  self.site = 'https://services.arcgis.com/8ZpVMShClf8U8dae/ArcGIS/rest/'\
              'services/TestingLocations_public/FeatureServer'
end

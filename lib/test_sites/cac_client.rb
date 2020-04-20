# frozen_string_literal: true

module TestSites
  # Client for: https://covidtracking.com/api
  class CACClient < APIClient
    ENDPOINT = 'https://api.findcovidtesting.com/api/v1'

    def initialize
      super(ENDPOINT)
    end

    def locations
      get('location', 'fetching CAC location data')
    end
  end
end

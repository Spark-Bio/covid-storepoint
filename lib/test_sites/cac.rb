# frozen_string_literal: true

require 'faraday'
require 'geodesics'
require 'hashie'
require 'jaro_winkler'

module TestSites
  MILES_PER_METER = (1 / 1609.344)

  # Overrides Hashie::Mash to disable warnings.
  class NoWarningMash < Hashie::Mash
    disable_warnings
  end

  # Utility class for processing Coders Against Covid location data.
  class CAC
    SEPARATOR = ' - '

    def dump_matches
      CSV.open(DataFile.path('cac_comparison.csv'),
               'w',
               write_headers: true,
               headers: ['Jaro-Winkler', 'Geo Distance', 'Ours',
                         'Closest CAC Match']) do |csv|
        closest_matches.each do |match|
          csv << match
        end
      end
    end

    def cac_data
      @cac_data ||= Hashie::Array.new(JSON.parse(cac_raw_data))
    end

    private

    def local_data
      @local_data ||= CSV.read('test/fixtures/store_point.csv', headers: true)
    end

    def cac_raw_data
      Faraday.get('https://api.findcovidtesting.com/api/v1/location').body
    end

    def cac_by_address
      @cac_by_address ||=
        cac_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw)
          address = [entry.location_address_street,
                     entry.location_address_locality,
                     entry.location_address_region,
                     entry.location_address_postal_code].join(SEPARATOR)
          acc[address] = entry
        end
    end

    def local_by_address
      @local_by_address ||=
        local_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw.to_h)
          address = [entry.address,
                     entry.city,
                     entry.state,
                     entry.postcode].join(SEPARATOR)
          acc[address] = entry
        end
    end

    # rubocop:disable Metrics/MethodLength, Style/MultilineBlockChain
    def closest_matches
      local_by_address.map do |local_addr, local_value|
        cac_same_state = cac_for_state(local_value.state)
        closest_add_match_cac = cac_same_state.max_by do |cac_addr, _|
          JaroWinkler.distance local_addr, cac_addr
        end
        closet_cac_addr, closest_cac_value = closest_add_match_cac
        if closet_cac_addr
          dist = distance_miles(local_value, closest_cac_value)
          [JaroWinkler.distance(local_addr, closet_cac_addr), dist, local_addr,
           closet_cac_addr]
        else
          ['-', '-', local_addr, '-']
        end
      end.sort_by { |e| e.first.is_a?(Float) ? -e.first : 999_999 }
    end
    # rubocop:enable Metrics/MethodLength, Style/MultilineBlockChain

    def cac_for_state(state)
      cac_by_address.filter do |_, cac_value|
        cac_value.location_address_region == state
      end.to_h
    end

    def distance_miles(local_value, cac_value)
      unless cac_value&.location_latitude && cac_value&.location_longitude
        return 'unknown'
      end

      distance = Geodesics.distance(
        local_value.lat.to_f, local_value.lng.to_f,
        cac_value.location_latitude.to_f, cac_value.location_longitude.to_f
      ) * MILES_PER_METER

      distance.round(1)
    end
  end
end

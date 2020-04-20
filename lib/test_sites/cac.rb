# frozen_string_literal: true

require 'faraday'
require 'geodesics'
require 'hashie'
require 'jaro_winkler'

module TestSites
  MILES_PER_METER = (1 / 1609.344)
  # Utility class for processing Coders Against Covid location data.
  class CAC
    SEPARATOR = ', '

    def self.all_hours
      CAC.cac_data.map { |cac_entry| cac_entry['location_hours_of_operation'] }
    end

    def self.cac_data
      TestSites::CACClient.new.locations.map do |location|
        if location.location_address_region.nil?
          address = StreetAddress::US.parse(location.location_address_street)
          location.location_address_region = address&.state
        end
        location
      end
    end

    def dump_matches
      CSV.open(DataFile.path('cac_comparison.csv'),
               'w',
               write_headers: true,
               headers: ['Jaro-Winkler (address)', 'Geo Distance', 'SB - Addr',
                         'SB - Name', 'Closest CAC Match - Addr',
                         'Closest CAC Match - Name']) do |csv|
        closest_matches.each do |match|
          csv << match
        end
      end
    end

    private

    def cac_by_address
      @cac_by_address ||=
        CAC.cac_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw)
          address = entry.location_address_street

          # Seems that CAC is returning null for everything other than
          # street. Hopefully they'll start providing the structured data
          # again.
          # address = [entry.location_address_street,
          #            entry.location_address_locality,
          #            entry.location_address_region,
          #            entry.location_address_postal_code].join(SEPARATOR)
          acc[address] = entry
        end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def local_by_address
      @local_by_address ||=
        StorePoint.local_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw.to_h)
          unless entry.address && entry.city && entry.state && entry.postcode
            next
          end

          address = [entry.address,
                     entry.city,
                     [entry.state, entry.postcode].join(' ')].join(SEPARATOR)
          acc[address] = entry
        end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def closest_matches
      matches =
        local_by_address.map do |local_addr, local_value|
          closest_match(local_addr, local_value)
        end.compact
      matches.sort_by { |e| e.first.is_a?(Float) ? e.first : -1 }
    end

    # Returns the closest match for a given test site entry, where closeness is
    # defined in terms of Jaro-Winkler distance between the address strings.
    def closest_match(local_addr, local_value)
      closet_cac_addr, closest_cac_value =
        closest_addr_match_cac(local_value, local_addr)
      return unless closet_cac_addr

      cac_match_summary(
        local_addr, local_value, closet_cac_addr, closest_cac_value
      )
    end

    def cac_match_summary(
      local_addr, local_value, closet_cac_addr, closest_cac_value
    )
      [
        JaroWinkler.distance(local_addr, closet_cac_addr),
        distance_miles(local_value, closest_cac_value),
        local_addr,
        local_value.name,
        closet_cac_addr,
        closest_cac_value.location_name
      ]
    end

    def closest_addr_match_cac(local_value, local_addr)
      cac_for_state(local_value.state).max_by do |cac_addr, _|
        JaroWinkler.distance local_addr, cac_addr
      end
    end

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

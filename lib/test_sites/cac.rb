# frozen_string_literal: true

require 'hashie'
require 'faraday'
require 'jaro_winkler'

module TestSites
  class NoWarningMash < Hashie::Mash
    disable_warnings
  end

  class CAC
    SEPARATOR = ' - '

    def dump_matches
      CSV.open(DataFile.path('cac_comparison.csv'),
               'w',
               write_headers: true,
               headers: ['Jaro-Winkler distance', 'ours', 'closest CAC match']) do |csv|
        closest_matches.each do |match|
          csv << match
        end
      end
    end

    private

    def cac_data
      @cac_data ||= Hashie::Array.new(JSON.parse(cac_raw_data))
    end

    def cac_raw_data
      Faraday.get('https://api.findcovidtesting.com/api/v1/location').body
    end

    def local_data
      @local_data ||= CSV.read(DataFile.path('store_point.csv'), headers: true)
    end

    def cac_by_address
      @cac_by_address ||=
        cac_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw)
          address = [
            entry.location_address_street,
            entry.location_address_locality,
            entry.location_address_region,
            entry.location_address_postal_code
          ].join(SEPARATOR)
          acc[address] = entry
        end
    end

    def local_by_address
      @local_by_address ||=
        local_data.each_with_object({}) do |entry_raw, acc|
          entry = NoWarningMash.new(entry_raw.to_h)
          address = [
            entry.address,
            entry.city,
            entry.state,
            entry.postcode
          ].join(SEPARATOR)
          acc[address] = entry
        end
    end

    def closest_matches
      closest_matches =
        local_by_address.keys.map do |local_addr|
          closest =
            cac_by_address.keys.max_by do |cac_addr|
              JaroWinkler.distance local_addr, cac_addr
            end
          [JaroWinkler.distance(local_addr, closest), local_addr, closest]
        end.sort_by { |e| -e.first }
    end
  end
end

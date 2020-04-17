# frozen_string_literal: true

require 'json'

module TestSites
  # Wrapper for results from geocoder API.
  class GeocoderResult
    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    # test if two GeocoderResults are equal on the fields we care about
    def equal?(other)
      %i[street_number route intersection premise subpremise city postcode
         state].each_with_object({}) do |type, acc|
        acc && (send(type) == other.send(type))
      end
    end

    def all_equal?(others)
      others.each_with_object({}) do |other, acc|
        acc && equal?(other)
      end
    end

    def street_number
      component(:street_number)
    end

    def route
      component(:route)
    end

    def intersection
      component(:intersection)
    end

    def premise
      component(:premise)
    end

    def subpremise
      component(:subpremise)
    end

    def city
      component(:locality)
    end

    def postcode
      component(:postal_code)
    end

    def state
      component(:administrative_area_level_1)
    end

    def component(type)
      value = address_components[type] || []
      if value.size > 1
        raise "Multiple #{type} components for #{display_address}: "\
              "#{value.join(', ')}"
      end

      value.first
    end

    def display_address
      raw.display_address
    end

    def lat
      location.lat
    end

    def lng
      location.lng
    end

    def formatted_address
      raw.formatted_address
    end

    def location
      raw.geometry.location
    end

    def address_components
      @address_components =
        Hashie::Mash.new(
          raw.address_components.each_with_object({}) do |h, acc|
            h.types.each do |type_str|
              type = type_str.to_sym
              acc[type] ||= []
              acc[type] << (type == 'premise' ? h.long_name : h.short_name)
            end
          end
        )
    end
  end
end

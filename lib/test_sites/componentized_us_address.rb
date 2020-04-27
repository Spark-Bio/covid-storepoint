# frozen_string_literal: true

require 'street_address'

module TestSites
  # US Address with street / city / state / zip components, based
  # on a Google Geocoding API result.
  class ComponentizedUSAddress
    def initialize(geocoder_result)
      @geocoder_result = geocoder_result
    end

    def street
      intersection || street_addresss
    end

    def city
      @geocoder_result&.city
    end

    def state
      @geocoder_result&.state
    end

    def zip
      @geocoder_result&.postcode
    end

    private

    def street_addresss
      if @geocoder_result&.street_number && @geocoder_result&.route
        [
          @geocoder_result&.street_number,
          @geocoder_result&.route,
          @geocoder_result&.subpremise
        ].compact.join(' ')
      else
        street_address_fallback
      end
    end

    def intersection
      @geocoder_result&.intersection
    end

    def street_address_fallback
      if @geocoder_result&.formatted_address
        address = StreetAddress::US.parse(implicit_us_address)
        if address&.number && address&.street && address&.street_type
          "#{address.number} #{address.street} #{address.street_type}"
        end
      end || nil
    end

    def implicit_us_address
      @geocoder_result&.formatted_address&.gsub(/, USA?/, '')
    end
  end
end

# frozen_string_literal: true

require 'hashie'
require 'street_address'

module TestSites
  # Wrapper class for test site locations.
  class Listing
    attr_accessor :source_entry
    attr_reader :geocoder_result

    EMPTY_HOURS = ((0..6).map { '' }).to_a.freeze

    def initialize(source_entry, geocoder_result)
      @source_entry = source_entry
      @geocoder_result = geocoder_result
    end

    delegate :name, :phone, :hours, to: :source_entry

    def raw_address
      source_entry.address
    end

    def description
      s = source_entry.instructions
      s&.downcase == 'undefined' ? '' : s
    end

    def address
      intersection || street_address
    end

    def intersection
      address_components.intersection&.first
    end

    def street_address
      if street_number && route
        [street_number, route, subpremise].compact.join(' ')
      else
        street_address_fallback
      end
    end

    delegate :street_number, :route, :intersection, :premise, :subpremise,
             :city, :postcode, :state, :lat, :lng, :formatted_address,
             to: :geocoder_result

    def country
      ''
    end

    def website
      source_entry.url_source
    end

    def email
      ''
    end

    def monday
      hours_array[0]
    end

    def tuesday
      hours_array[1]
    end

    def wednesday
      hours_array[2]
    end

    def thursday
      hours_array[3]
    end

    def friday
      hours_array[4]
    end

    def saturday
      hours_array[5]
    end

    def sunday
      hours_array[6]
    end

    def tags
      source_entry.facility_type&.split('/')&.join(', ')
    end

    def extra
      ''
    end

    private

    def hours_array
      @hours_array ||=
        begin
        spec = hour_parser.parse(hours)
        spec&.to_array || EMPTY_HOURS
      end
    end

    def street_address_fallback
      if formatted_address
        implicit_us_address = formatted_address.gsub(/, USA?/, '')
        address = StreetAddress::US.parse(implicit_us_address)
        if address&.number && address&.street && address&.street_type
          "#{address.number} #{address.street} #{address.street_type}"
        end
      end || nil
    end

    def hour_parser
      @hour_parser ||= HourParser.new
    end
  end
end

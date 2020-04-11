# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class Listings
    def listings
      source.entries_with_geocoding.map do |source_entry|
        Listing.new(source_entry, source.geocoder_result_for_source_entry(source_entry))
      end
    end

    def source
      @source ||= Source.new
    end
  end
end

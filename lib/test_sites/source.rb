# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'csv'
require 'hashie'
require 'json'

module TestSites
  class Source
    include Enumerable
    SOURCE_FILE = DataFile.path('current_source.csv')

    delegate :each, :size, to: :entries

    def entries_with_geocoding
      entries_with_addresses.filter do |source_entry|
        geocoder_result_for_source_entry(source_entry)
      end
    end

    def geocoder_result_for_source_entry(source_entry)
      geocoder_results.filtered[source_entry.address]
    end

    def entries_with_addresses
      entries.find_all do |source_entry|
        geocoder_results.filtered[source_entry.address]
      end
    end

    def dup_addresses
      original_addrs = entries.map(&:address)
      original_addrs.find_all { |addr| original_addrs.count(addr) > 1 }.sort
    end

    def entries
      @entries ||=
        CSV.read(SOURCE_FILE, headers: true, skip_blanks: true).map do |csv_row|
          SourceEntry.new(csv_row)
        end.reject { |se| se.raw_data.blank? }
    end

    def all_hours
      entries.map(&:hours).compact.sort.uniq
    end

    def geocoder_results
      @geocoder_results ||= GeocoderResults.new
    end
  end
end

# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'csv'
require 'hashie'
require 'json'
require 'xsv'

module TestSites
  # Wrapper class for Evite locations file.
  class Source
    include Enumerable
    CURRENT_SOURCE_FILE = DataFile.path('current_source.csv')
    CSV_OPTIONS = { headers: true, skip_blanks: true }.freeze

    attr_reader :source_file, :exclude_ignored
    delegate :each, :size, to: :entries

    def initialize(source_file: CURRENT_SOURCE_FILE, exclude_ignored: true)
      @source_file = source_file
      @exclude_ignored = exclude_ignored
    end

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
      dup_values('address')
    end

    def dup_primary_keys
      dup_values('primary_key')
    end

    def dup_values(attribute)
      vals = entries.map { |source_entry| source_entry.send(attribute) }
      vals.find_all { |val| vals.count(val) > 1 }.sort
    end

    def entries
      @entries ||= csv.map do |csv_row|
        SourceEntry.new(csv_row)
      end.reject(&:empty?)
    end

    def csv
      source_file_ext = File.extname(source_file)
      csv = case source_file_ext
            when '.csv'
              csv_from_csv_file(source_file)
            when '.xlsx'
              csv_from_excel_file(source_file)
            else
              raise "Unknown file extension #{source_file_ext}"
            end
      exclude_ignored ? csv.filter { |row| row['Ignore'].blank? } : csv
    end

    def csv_from_csv_file(source_file)
      CSV.open(source_file, 'r:bom|utf-8', **CSV_OPTIONS).to_a
    end

    def csv_from_excel_file(source_file)
      CSV.parse(excel_to_csv_string(source_file), **CSV_OPTIONS)
    end

    def excel_to_csv_string(source_file)
      Xsv::Workbook.open(source_file).sheets.last.to_a.map(&:to_csv).join
    end

    def all_hours
      entries.map(&:hours).compact.sort.uniq
    end

    def primary_keys
      @primary_keys ||= entries.map(&:primary_key).uniq
    end

    def check_dup_primary_keys
      return unless dup_primary_keys.any?

      raise "Duplicate primary keys found: #{dup_primary_keys.join("\n")}"
    end

    def geocoder_results
      @geocoder_results ||= GeocoderResults.new
    end
  end
end

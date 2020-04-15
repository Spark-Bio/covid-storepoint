# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'csv'
require 'hashie'
require 'json'

module TestSites
  class SourceEntry
    STATE_HEADER = 'State'
    NAME_HEADER = 'Testing Site Name'
    FACILITY_TYPE_HEADER = 'Facility Type'
    ADDRESS_HEADER = 'Testing Site Address'
    ZIP_HEADER = 'Testing Site Zip'
    PHONE_HEADER = 'Testing Site Phone Number'
    HOURS_HEADER = 'Testing Site Hours'
    INSTRUCTIONS_HEADER = 'Instructions'
    URL_SOURCE_HEADER = 'URL Source'
    KEY_ADDRESS_HEADER = 'Key Address'
    KEY_NAME_HEADER = 'Key Name'
    IGNORED_HEADER = 'Exclude Entry?'

    def initialize(raw_data, source)
      @raw_data = raw_data
      @source = source
    end

    def primary_key
      [state, key_name, key_address].join('|')
    end

    def state
      raw_value(STATE_HEADER)
    end

    def name
      raw_value(NAME_HEADER)
    end

    def facility_type
      raw_value(FACILITY_TYPE_HEADER)
    end

    def address
      raw_value(ADDRESS_HEADER)
    end

    def phone
      raw_value(PHONE_HEADER)
    end

    def hours
      raw_value(HOURS_HEADER)
    end

    def instructions
      raw_value(INSTRUCTIONS_HEADER)
    end

    def url_source
      raw_value(URL_SOURCE_HEADER)
    end

    def key_name
      key_field(KEY_NAME_HEADER, name)
    end

    def key_address
      key_field(KEY_ADDRESS_HEADER, address)
    end

    def state_and_name_match?(other)
      state == other.state && name == other.name
    end

    def hash
      %w[state name facility_type address zip phone hours url_source].map { |method_name| send(method_name) }.hash
    end

    def ==(other)
      hash == other.hash
    end

    def eql?(other)
      (self.class == other.class) && (self == other)
    end

    def empty?
      raw_data.empty?
    end

    private

    attr_reader :raw_data

    def raw_value(field)
      normalize_whitespace(raw_data[field])
    end

    def normalize_whitespace(s)
      s&.strip&.gsub(/\s+/, ' ')
    end

    def key_field(header, field)
      if raw_data.header?(header)
        normalize_whitespace(raw_data[header])
      else
        field
      end
    end
  end
end

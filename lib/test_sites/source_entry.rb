# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class SourceEntry
    attr_reader :raw_data

    STATE_HEADER = 'State'
    NAME_HEADER = 'Testing Site Name'
    ADDRESS_HEADER = 'Testing Site Address'
    HOURS_HEADER = 'Testing Site Hours'
    KEY_ADDRESS_HEADER = 'Key Address'
    KEY_NAME_HEADER = 'Key Name'

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

    def address
      raw_value(ADDRESS_HEADER)
    end

    def hours
      raw_value(HOURS_HEADER)
    end

    def key_name
      key_field(KEY_NAME_HEADER, name)
    end

    def key_address
      key_field(KEY_ADDRESS_HEADER, address)
    end

    def key_field(header, field)
      if raw_data.header?(header)
        normalize_whitespace(raw_data[header])
      else
        field
      end
    end

    def state_and_name_match?(other)
      state == other.state && name == other.name
    end

    def raw_value(field)
      normalize_whitespace(raw_data[field])
    end

    def normalize_whitespace(s)
      s&.strip&.gsub(/\s+/, ' ')
    end
  end
end

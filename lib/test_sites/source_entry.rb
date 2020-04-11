# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class SourceEntry
    attr_reader :raw_data

    STATE_KEY = 'State'
    NAME_KEY = 'Testing Site Name'
    ADDRESS_KEY = 'Testing Site Address'
    HOURS_KEY = 'Testing Site Hours'

    def initialize(raw_data)
      @raw_data = raw_data
    end

    def primary_key
      [state, name, address].join('|')
    end

    def state
      raw_data[STATE_KEY]
    end

    def name
      raw_data[NAME_KEY]
    end

    def address
      raw_data[ADDRESS_KEY]
    end

    def hours
      raw_data[HOURS_KEY]
    end

    def state_and_name_match?(other)
      state == other.state && name == other.name
    end
  end
end

# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'

module TestSites
  class HourSpecifier
    attr_accessor :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
    attr_accessor :while_supplies_last
    attr_accessor :by_appt_only

    DAYS_OF_THE_WEEK = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

    def initialize(monday = '', tuesday = '', wednesday = '', thursday = '', friday = '', saturday = '', sunday = '', by_appt_only: false)
      @monday = monday
      @tuesday = tuesday
      @wednesday = wednesday
      @thursday = thursday
      @friday = friday
      @saturday = saturday
      @sunday = sunday
      @while_supplies_last = false
      @by_appt_only = by_appt_only
    end

    def merge(other_specifier)
      %i[monday tuesday wednesday thursday friday saturday sunday].each do |day|
        curr_val = send(day)
        other_spec_val = other_specifier.send(day.to_s)
        if curr_val.blank? && other_spec_val.present?
          send("#{day}=", other_spec_val)
        end
      end
    end

    def to_array
      DAYS_OF_THE_WEEK.map do |day|
        send(day)
      end
    end
  end
end

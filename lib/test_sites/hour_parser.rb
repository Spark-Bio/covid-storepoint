# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'csv'
require 'hashie'
require 'json'

module TestSites
  # rubocop:disable Metrics/ClassLength
  # Utility class for parsing hours from location data.
  class HourParser
    DAYS_OF_THE_WEEK = %w[Monday Tuesday Wednesday Thursday Friday Saturday
                          Sunday].freeze

    START_TIME_ONLY =
      '(opens?\\s+)?(?<start_time>\d{1,2}(:\d{1,2})?)' \
      '\s*(?<start_ampm>a\.?(m\.?)?|p\.?(m\.?)?)'

    TIME_RANGE =
      '(?<start_time>\d{1,2}(:\d{1,2})?)' \
      '\s*(?<start_ampm>a\.?(m\.?)?|p\.?(m\.?)?)' \
      '\s*(-|–|to|til|until|&)' \
      '\s*(?<end_time>\d{1,2}(:\d{1,2})?)' \
      '\s*(?<end_ampm>a\.?(m\.?)?|p\.?(m\.?)?)'
    TIME_RANGE_2 = TIME_RANGE.gsub('time>', 'time_2>').gsub('ampm>', 'ampm_2>')
    DAY_OF_WEEK = DAYS_OF_THE_WEEK.map { |d| "#{d}s?" } .join('|')
    DAY_RANGE =
      "(?<start_day>#{DAY_OF_WEEK})\\s*(-|–|through|thru|to|&)\\s*(?<end_day>"\
      "#{DAY_OF_WEEK})"
    DAY_TIME_RANGE = "#{DAY_RANGE}(:|,)?\\s*#{TIME_RANGE}"
    TIME_DAY_RANGE = "#{TIME_RANGE},?\\s*#{DAY_RANGE}"

    TWO_TIME_DAY_RANGE =
      "#{TIME_RANGE}\\s*(and|&)?\\s*#{TIME_RANGE_2}\\s*,?\\s*#{DAY_RANGE}"
    DAY_TWO_TIME_RANGE =
      "#{DAY_RANGE},?\\s#{TIME_RANGE}\\s*(and|&)\\s*?#{TIME_RANGE_2}"

    DAILY = '(daily|every day|(seven|7) days\s*(a|per|\/)\s*week)\.?'

    EVERY_DAY_START_TIME = "#{START_TIME_ONLY},?\\s+#{DAILY}"
    EVERY_DAY_RANGE = "#{TIME_RANGE},?\\s+#{DAILY}"
    WEEKDAYS_RANGE = "#{TIME_RANGE},?\\s+(weekdays)"
    CERTAIN_DAYS_TIME_DAY =
      "#{TIME_RANGE},?\\s*(?<days>((#{DAY_OF_WEEK})\\s*,?(\\s*and)?\\s*)+)"
    CERTAIN_DAYS_DAY_TIME =
      "(?<days>((#{DAY_OF_WEEK})\\s*,?(\\s*and)?\\s*)+):?\\s*#{TIME_RANGE}"

    START_TIME_DAYS = "#{START_TIME_ONLY}(:|,)?\\s*#{DAY_RANGE}"
    DAYS_START_TIME = "#{DAY_RANGE}(:|,)?\\s*#{START_TIME_ONLY}"

    # rubocop:disable Layout/LineLength
    BY_APPT_ONLY = /(?<phrase>(;|,|:)?\s*by appointment(\s*only)?\.?(\s*open daily)?(\.|:)?)/i.freeze

    HS_CHECK_WEBSITE = HourSpecifier.new(*Array.new(7,  'check website'))
    HS_CALL = HourSpecifier.new(*Array.new(7, 'call for hours'))
    HS_24_7 = HourSpecifier.new(*Array.new(7, '24 hours'))
    HS_NOT_YET_AVAILABLE = HourSpecifier.new(*Array.new(7, 'not yet available'))
    HS_BY_APPT_ONLY = HourSpecifier.new(by_appt_only: true)

    WHILE_SUPPLIES_LAST = /(?<phrase>\s*(as|while|until)(\s+that site's)?\s+(supplies|(test\s*)?kits|(daily\s*)?limits)\s+(last|run out|have been reached))/i.freeze
    # rubocop:enable Layout/LineLength

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def parse(raw)
      while_supplies_last = WHILE_SUPPLIES_LAST =~ raw
      raw = raw.gsub($LAST_MATCH_INFO[:phrase], '') if while_supplies_last

      by_appt_only = BY_APPT_ONLY =~ raw
      raw = raw.gsub($LAST_MATCH_INFO[:phrase], '') if by_appt_only

      spec = range(raw, while_supplies_last, by_appt_only)
      unless spec
        if raw =~ /;/
          specs = raw.split(';').map do |component|
            range(component, while_supplies_last, by_appt_only)
          end
          unless specs.compact.size < specs.size
            spec = specs.each_with_object(HourSpecifier.new) do |spec2, acc|
              acc.merge(spec2)
            end
          end
        end
      end

      spec.while_supplies_last = true if spec && while_supplies_last

      spec
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def range(raw, while_supplies_last, by_appt_only)
      s = raw&.downcase&.strip
      return nil if s.blank? && !by_appt_only

      s = s.gsub(/weekdays/i, 'Monday - Friday')
      s = s.gsub(/weekends/i, 'Saturday - Sunday')

      if ['call', 'call to confirm', 'call to confirm for hours',
          'call to confirm hours', 'check with facility'].include?(s)
        HS_CALL
      elsif ['check website'].include?(s)
        HS_CHECK_WEBSITE
      elsif ['24/7', '24 hours', 'open 24 hours', 'open 24hrs', 'open 24 hrs']
            .include?(s)
        HS_24_7
      elsif ['not available', 'not specified at this time.',
             'not yet available', 'currently not accepting appointments.',
             'currently closed.', 'temporarily closed'].include?(s)
        HS_NOT_YET_AVAILABLE
      elsif by_appt_only && s.blank?
        every_day_specifier('by appointment only')
      elsif s =~ re(TIME_RANGE)
        every_day_specifier(normalize_time_span($LAST_MATCH_INFO))
      elsif s =~ re(EVERY_DAY_RANGE)
        same_time_some_days($LAST_MATCH_INFO, DAYS_OF_THE_WEEK, by_appt_only)
      elsif s =~ re(WEEKDAYS_RANGE)
        same_time_some_days($LAST_MATCH_INFO,
                            DAYS_OF_THE_WEEK - %w[Saturday Sunday],
                            by_appt_only)
      elsif s =~ re(TIME_DAY_RANGE) || s =~ re(DAY_TIME_RANGE)
        day_time_specifier($LAST_MATCH_INFO, by_appt_only)
      elsif s =~ re(CERTAIN_DAYS_TIME_DAY) || s =~ re(CERTAIN_DAYS_DAY_TIME)
        same_time_some_days($LAST_MATCH_INFO,
                            normalize_day_list($LAST_MATCH_INFO),
                            by_appt_only)
      elsif s =~ re(START_TIME_DAYS) || s =~ re(DAYS_START_TIME)
        start_time_only($LAST_MATCH_INFO, while_supplies_last, by_appt_only)
      elsif s =~ re(EVERY_DAY_START_TIME)
        start_time_only_days($LAST_MATCH_INFO, DAYS_OF_THE_WEEK,
                             while_supplies_last, by_appt_only)
      elsif s =~ re(TWO_TIME_DAY_RANGE) || s =~ re(DAY_TWO_TIME_RANGE)
        day_two_time_specifier($LAST_MATCH_INFO)
      elsif s =~ re(DAY_RANGE)
        day_range_specifier($LAST_MATCH_INFO, while_supplies_last, by_appt_only)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def normalize_day_list(match)
      match[:days].gsub(',', '').gsub(' and', ' ').gsub(/\s+/, ' ').split(' ')
                  .map(&:capitalize)
    end

    def day_time_specifier(match, by_appt_only)
      days = expand_day_span(match)
      same_time_some_days(match, days, by_appt_only)
    end

    def same_time_some_days(match, days, by_appt_only)
      time_span = normalize_time_span(match)
      time_span = handle_by_appt_only(time_span, by_appt_only)
      create_spec(days, time_span)
    end

    def create_spec(days, time_span)
      HourSpecifier.new.tap do |hs|
        days.each do |day|
          hs.send("#{normalize_day(day).downcase}=", time_span)
        end
      end
    end

    def day_two_time_specifier(match)
      days = expand_day_span(match)
      same_two_times_some_days(match, days)
    end

    def same_two_times_some_days(match, days)
      time_span1 = normalize_time_span(match)
      time_span2 = normalize_time_span_2(match)
      time_span = "#{time_span1} and #{time_span2}"
      HourSpecifier.new.tap do |hs|
        days.each do |day|
          hs.send("#{normalize_day(day).downcase}=", time_span)
        end
      end
    end

    def start_time_only(match, while_supplies_last, by_appt_only)
      days = expand_day_span(match)
      start_time_only_days(match, days, while_supplies_last, by_appt_only)
    end

    def start_time_only_days(match, days, while_supplies_last, by_appt_only)
      time_span = normalize_time(match[:start_time], match[:start_ampm])
      time_span = handle_while_supplies_last(time_span, while_supplies_last)
      time_span = handle_by_appt_only(time_span, by_appt_only)
      create_spec(days, time_span)
    end

    def normalize_time(time, ampm)
      "#{time}#{ampm.gsub('.', '').upcase}"
    end

    def normalize_time_span(match)
      start_time = normalize_time(match[:start_time], match[:start_ampm])
      end_time = normalize_time(match[:end_time], match[:end_ampm])
      format_range(start_time, end_time)
    end

    def normalize_time_span_2(match)
      start_time = normalize_time(match[:start_time_2], match[:start_ampm_2])
      end_time = normalize_time(match[:end_time_2], match[:end_ampm_2])
      format_range(start_time, end_time)
    end

    def format_range(start_time, end_time)
      "#{start_time}-#{end_time}"
    end

    def expand_day_span(match)
      start_day = day_index(match[:start_day])
      end_day = day_index(match[:end_day])
      if start_day <= end_day
        DAYS_OF_THE_WEEK[start_day..end_day]
      else
        DAYS_OF_THE_WEEK - DAYS_OF_THE_WEEK[(end_day + 1)..(start_day - 1)]
      end
    end

    def day_range_specifier(match, while_supplies_last, by_appt_only)
      days = expand_day_span(match)
      time_span = ''
      time_span = handle_while_supplies_last(time_span, while_supplies_last)
      time_span = handle_by_appt_only(time_span, by_appt_only)
      time_span = 'call for hours' if time_span.blank?
      create_spec(days, time_span)
    end

    def day_index(day)
      DAYS_OF_THE_WEEK.find_index(normalize_day(day))
    end

    def normalize_day(day)
      day.capitalize.gsub(/s$/, '')
    end

    def re(string)
      Regexp.new("^#{string}$", Regexp::IGNORECASE)
    end

    def every_day_specifier(string)
      HourSpecifier.new(*Array.new(7, string))
    end

    def handle_by_appt_only(string, by_appt_only)
      by_appt_only ? string + ' by appointment only' : string
    end

    def handle_while_supplies_last(string, while_supplies_last)
      while_supplies_last ? string + ' until supplies run out' : string
    end

    # rubocop:disable Metrics/AbcSize
    def check_all
      found = all_hours.filter { |d| parse(d) }.compact
      hours_left = all_hours - found
      if hours_left.any?
        puts "Hour specifiers that couldn't be parsed:"
        puts hours_left.map { |spec| "* #{spec}" }.join("\n")
      end
      puts "Hour specifiers: parsed #{found.size} out of #{all_hours.size}"
    end
    # rubocop:enable Metrics/AbcSize

    def all_hours
      @all_hours ||= TestSites::Source.new.all_hours
    end
  end
  # rubocop:enable Metrics/ClassLength
end

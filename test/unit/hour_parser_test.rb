# frozen_string_literal: false

require 'test_helper'

class HourParserTest < TestSitesTestCase
  def setup
    @hour_parser = TestSites::HourParser.new
  end

  def test_parser
    hours = @hour_parser.parse('8am-9pm every day').to_array
    assert_equal hours, Array.new(7, '8AM-9PM')
  end

  def test_24_hour_single_day_specifier
    hours = @hour_parser.parse('8:00 am - 4:30 pm Monday, Tuesday, Wednesday, '\
      'Thursday, Friday; 24 hours Sunday').to_array
    assert_equal hours, ['8:00AM-4:30PM',
                         '8:00AM-4:30PM',
                         '8:00AM-4:30PM',
                         '8:00AM-4:30PM',
                         '8:00AM-4:30PM',
                         '',
                         '24 hours']
  end
end

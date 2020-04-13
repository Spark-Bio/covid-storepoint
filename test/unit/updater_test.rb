# frozen_string_literal: false

require 'test_helper'

class HourParserTest < TestSitesTestCase
  def test_parser
    hour_parser = TestSites::HourParser.new
    hours = hour_parser.parse('8am-9pm every day').to_array
    assert_equal hours, Array.new(7, '8AM-9PM')
  end
end

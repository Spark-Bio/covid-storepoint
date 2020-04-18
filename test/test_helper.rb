# frozen_string_literal: true

# Include our application
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
load 'test_sites.rb' unless defined?(TestSites)

require 'minitest/autorun'

class TestSitesTestCase < Minitest::Test
end

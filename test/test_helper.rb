# frozen_string_literal: true

# Include our application
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
load 'test_sites.rb' unless defined?(TestSites)
load 'models.rb' unless defined?(Models)

require 'minitest/autorun'
require 'pry'

class TestSitesTestCase < Minitest::Test
end

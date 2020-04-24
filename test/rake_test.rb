# frozen_string_literal: false

require 'test_helper'

class RakeTest < TestSitesTestCase
  Rake.application.load_rakefile

  def test_check_cac_hours
    return if ENV['GITHUB_RUN_ID'] # skip integration test if running on github

    Rake.application.invoke_task 'check_cac_hours'
  end

  def test_compare_cac
    return if ENV['GITHUB_RUN_ID'] # skip integration test if running on github

    Rake.application.invoke_task 'compare_cac'
    assert FileUtils.compare_file('data/cac_comparison.csv',
                                  'test/fixtures/cac_comparison.csv')
  end

  def test_geocode_cac_locations
    Rake.application.invoke_task 'geocode_cac_locations'
  end

  def test_update_storepoint
    Rake.application.invoke_task 'update_storepoint'
    assert FileUtils.compare_file('data/store_point.csv',
                                  'test/fixtures/store_point.csv')
  end
end

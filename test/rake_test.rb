# frozen_string_literal: false

require 'test_helper'

class RakeTest < TestSitesTestCase
  Rake.application.load_rakefile

  def test_compare_cac
    unless ENV['GITHUB_RUN_ID'] # skip integration test if running on github
      Rake.application.invoke_task 'compare_cac'
      assert_true FileUtils.compare_file('data/cac_comparison.csv', 'test/fixtures/cac_comparison.csv')
    end
  end

  def test_export_cac_as_storepoint
    Rake.application.invoke_task 'export_cac_as_storepoint'
  end

  def test_update_storepoint
    Rake.application.invoke_task 'update_storepoint'
    assert_true FileUtils.compare_file('data/store_point.csv', 'test/fixtures/store_point.csv')
  end
end

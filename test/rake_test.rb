# frozen_string_literal: false

require 'test_helper'

class RakeTest < TestSitesTestCase
  def test_update_storepoint
    Rake.application.load_rakefile
    File.delete('data/store_point.csv')
    Rake.application.invoke_task 'update_storepoint'
    assert_true FileUtils.compare_file('data/store_point.csv', 'test/fixtures/store_point.csv')
  end
end

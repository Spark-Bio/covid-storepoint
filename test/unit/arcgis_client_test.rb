# frozen_string_literal: false

require 'test_helper'

class ArcGISClientTest < TestSitesTestCase
  def test_all
    refute_empty TestSites::ArcGISClient.all
  end

  def test_first
    first = TestSites::ArcGISClient.first
    assert_equal first.keys, %w[attributes geometry]
  end
end

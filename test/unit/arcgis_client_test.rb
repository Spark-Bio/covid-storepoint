# frozen_string_literal: false

require 'test_helper'

class ArcGISClientTest < TestSitesTestCase
  def test_all
    refute_empty TestSites::ArcGISClient.all
  end

  def test_locations
    assert_instance_of Hash, TestSites::ArcGISClient.locations
  end
end

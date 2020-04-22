# frozen_string_literal: false

require 'test_helper'

class ArcGISClientTest < TestSitesTestCase
  def test_all
    refute_empty TestSites::ArcGISClient.new.all
  end
end

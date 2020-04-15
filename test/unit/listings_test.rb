# frozen_string_literal: false

require 'test_helper'

class ListingsTest < TestSitesTestCase
  def test_listings
    TestSites::Listings.new.listings
  end
end

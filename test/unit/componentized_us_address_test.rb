# frozen_string_literal: false

require 'test_helper'

class ComponentizedUSAddressTest < TestSitesTestCase
  def setup
    @geocoder_results = TestSites::GeocoderResults.new.filtered
  end

  def test_has_street_address
    address = TestSites::ComponentizedUSAddress.new(
      @geocoder_results['600 Highland Ave., Madison WI 53792']
    )

    assert_equal '600 Highland Ave', address.street
    assert_equal 'Madison', address.city
    assert_equal 'WI', address.state
    assert_equal '53792', address.zip
  end

  def test_has_intersection
    address = TestSites::ComponentizedUSAddress.new(
      @geocoder_results['S Oakes St & E Beauregard Ave, San Angelo, TX 76903']
    )

    assert_equal 'S Oakes St & E Beauregard Ave', address.street
    assert_equal 'San Angelo', address.city
    assert_equal 'TX', address.state
    assert_equal '76903', address.zip
  end

  def test_has_subpremise
    address = TestSites::ComponentizedUSAddress.new(
      @geocoder_results['254 Ren Mar Dr, Suite 100 Pleasant View, TN 37146']
    )

    assert_equal '254 Ren Mar Dr #100', address.street
    assert_equal 'Pleasant View', address.city
    assert_equal 'TN', address.state
    assert_equal '37146', address.zip
  end
end

# frozen_string_literal: false

require 'models'
require 'test_helper'

class StorepointLocationTest < TestSitesTestCase
  ATTRIBUTES = {
    name: 'Tisch Hospital',
    description: 'At Tisch Hospital, we have more than 300',
    address: '550 First Avenue',
    city: 'New York',
    state: 'NY',
    postcode: '10016',
    country: 'USA',
    phone: '347-377-3708',
    website: 'https://nyulangone.org/locations/tisch-hospital',
    email: 'someone-at-tisch@nyulangone.org',
    monday: 'monday hours',
    tuesday: 'tuesday hours',
    wednesday: 'wednesday hours',
    thursday: 'thursday hours',
    friday: 'friday hours',
    saturday: 'saturday hours',
    sunday: 'sunday hours',
    tags: '#tag',
    extra: 'one more thing',
    lat: 40.7421225,
    lng: -73.9739642,
    hours: 'all hours'
  }.freeze

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_new
    location = StorepointLocation.new ATTRIBUTES
    assert location.name == 'Tisch Hospital'
    assert location.description == 'At Tisch Hospital, we have more than 300'
    assert location.address == '550 First Avenue'
    assert location.city == 'New York'
    assert location.state == 'NY'
    assert location.postcode == '10016'
    assert location.country == 'USA'
    assert location.phone == '347-377-3708'
    assert location.website == 'https://nyulangone.org/locations/tisch-hospital'
    assert location.email == 'someone-at-tisch@nyulangone.org'
    assert location.monday == 'monday hours'
    assert location.tuesday == 'tuesday hours'
    assert location.wednesday == 'wednesday hours'
    assert location.thursday == 'thursday hours'
    assert location.friday == 'friday hours'
    assert location.saturday == 'saturday hours'
    assert location.sunday == 'sunday hours'
    assert location.tags == '#tag'
    assert location.extra == 'one more thing'
    assert location.lat == 40.7421225
    assert location.lng == -73.9739642
    assert location.hours == 'all hours'
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end

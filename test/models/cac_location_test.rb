# frozen_string_literal: false

require 'test_helper'

# rubocop:disable Metrics/ClassLength
class CACLocationTest < TestSitesTestCase
  ATTRIBUTES = {
    'additional_information_for_patients':
      'At Tisch Hospital, we have more than 300',
    'created_on': 'Fri, 03 Apr 2020 00:17:24 GMT',
    'data_source': 'crowdsource',
    'deleted_on': nil,
    'external_location_id': nil,
    'geojson': nil,
    'is_collecting_samples': true,
    'is_collecting_samples_by_appointment_only': true,
    'is_collecting_samples_for_others': false,
    'is_collecting_samples_onsite': true,
    'is_evaluating_symptoms': true,
    'is_evaluating_symptoms_by_appointment_only': false,
    'is_hidden': false,
    'is_ordering_tests': true,
    'is_ordering_tests_only_for_those_who_meeting_criteria': true,
    'is_processing_samples': true,
    'is_processing_samples_for_others': false,
    'is_processing_samples_onsite': false,
    'is_verified': true,
    'location_address_locality': 'New York',
    'location_address_postal_code': '10016',
    'location_address_region': 'NY',
    'location_address_street': '550 First Avenue',
    'location_contact_phone_appointments': '347-377-3708',
    'location_contact_phone_covid': '347-377-3708',
    'location_contact_phone_main': '212-263-6906',
    'location_contact_url_covid_appointments': '',
    'location_contact_url_covid_info': '',
    'location_contact_url_covid_screening_tool': '',
    'location_contact_url_covid_virtual_visit': '',
    'location_contact_url_main':
        'https://nyulangone.org/locations/tisch-hospital',
    'location_hours_of_operation': '9am - 5pm',
    'location_id': '477556cd-efab-4da1-9cde-23f7ac27e607',
    'location_latitude': 40.7421225,
    'location_longitude': -73.9739642,
    'location_name': 'Tisch Hospital',
    'location_place_of_service_type': 'Hospital',
    'location_specific_testing_criteria':
      'https://coronavirus.health.ny.gov/covid-19-testing#overview',
    'location_status': '',
    'raw_data': nil,
    'record_id': 3082,
    'reference_publisher_of_criteria': nil,
    'updated_on': 'Fri, 03 Apr 2020 00:17:24 GMT'
  }.freeze

  ATTRIBUTES_ESRI = {
    'additional_information_for_patients':
  'https://www.capecodhealth.org/medical-services/infectious-disease/coronavirus/covid-19-testing-process/',
    'created_on': 'Sat, 11 Apr 2020 17:49:16 GMT',
    'data_source':
  '[GISCorps] https://www.capecodhealth.org/medical-services/infectious-disease/coronavirus/covid-19-testing-process/',
    'deleted_on': nil,
    'external_location_id':
  '[{"use": "primary", "kind": "esriFieldTypeOID", "alias": "OBJECTID", ' \
   '"field": "OBJECTID", "value": "4086", "system": "Esri", ' \
   '"assigner": "GISCorps"}' \
   ', null, {"use": "other", "kind": "esriFieldTypeGlobalID", "alias": ' \
    '"GlobalID", "field": "GlobalID", "value": ' \
    '"81e0292d-65fc-4fed-9cc8-5878719598e3", "system": "Esri", ' \
    '"assigner": "Esri"}]',
    'geojson': {},
    'is_collecting_samples': false,
    'is_collecting_samples_by_appointment_only': false,
    'is_collecting_samples_for_others': true,
    'is_collecting_samples_onsite': false,
    'is_evaluating_symptoms': false,
    'is_evaluating_symptoms_by_appointment_only': false,
    'is_hidden': false,
    'is_ordering_tests': false,
    'is_ordering_tests_only_for_those_who_meeting_criteria': true,
    'is_processing_samples': false,
    'is_processing_samples_for_others': false,
    'is_processing_samples_onsite': false,
    'is_verified': true,
    'location_address_locality': '',
    'location_address_postal_code': '',
    'location_address_region': nil,
    'location_address_street': '273 Teaticket Highway, Falmouth, MA 2540',
    'location_contact_phone_appointments': '',
    'location_contact_phone_covid': '',
    'location_contact_phone_main': '508-862-5595',
    'location_contact_url_covid_appointments': '',
    'location_contact_url_covid_info': '',
    'location_contact_url_covid_screening_tool': '',
    'location_contact_url_covid_virtual_visit': '',
    'location_contact_url_main':
  'https://www.barnstablecountyhealth.org/covid-19/latest-updates-and-info',
    'location_hours_of_operation': '',
    'location_id': 'c1750bd9-755e-0cb4-2beb-0807487e1460',
    'location_latitude': 41.5676230929044,
    'location_longitude': -70.5946701920671,
    'location_name': 'Cape Cod Healthcare Urgent Care - Falmouth',
    'location_place_of_service_type': 'Private',
    'location_specific_testing_criteria':
      'The day-to-day operations at this location are ...',
    'location_status': 'Operational',
    'raw_data': '{}',
    'record_id': 3235,
    'reference_publisher_of_criteria': '',
    'updated_on': 'Fri, 24 Apr 2020 12:50:49 GMT'
  }.freeze

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_to_storepoint
    assert storepoint_attr.keys.map(&:to_s) == TestSites::StorePoint::HEADERS
    assert storepoint_attr[:name] == 'Tisch Hospital'
    assert storepoint_attr[:description] ==
           'At Tisch Hospital, we have more than 300'
    assert storepoint_attr[:address] == '550 First Avenue'
    assert storepoint_attr[:city] == 'New York'
    assert storepoint_attr[:state] == 'NY'
    assert storepoint_attr[:postcode] == '10016'
    assert storepoint_attr[:phone] == '347-377-3708'
    assert storepoint_attr[:website] ==
           'https://nyulangone.org/locations/tisch-hospital'
    assert storepoint_attr[:tags] == 'Hospital'
    assert_in_delta storepoint_attr[:lat], 40.7421225
    assert_in_delta storepoint_attr[:lng], -73.9739642
    assert storepoint_attr[:hours] == '9am - 5pm'

    CACLocation::CAC_TO_STOREPOINT_MAPPING.each do |key, _value|
      next unless key.nil?

      skip "Skipping CACLocation##{key} because mapping is pending"
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def test_arcgis_global_id
    assert storepoint_esri.arcgis_global_id ==
           '81e0292d-65fc-4fed-9cc8-5878719598e3'
  end

  private

  def storepoint_attr
    @storepoint_attr ||= CACLocation.new(ATTRIBUTES).to_storepoint
  end

  def storepoint_esri
    @storepoint_esri ||= CACLocation.new(ATTRIBUTES_ESRI)
  end
end
# rubocop:enable Metrics/ClassLength

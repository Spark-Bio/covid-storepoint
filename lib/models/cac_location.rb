# frozen_string_literal: true

require 'active_model'
require 'test_sites'

# Represents a CAC testing-location.
#
# @example
#   location = CACLocation.new(location_name: 'Tisch Hospital',
#                              location_address_street: '550 First Avenue')
#   location.to_storepoint
#     => { address: '550 First Avenue', name: 'Tisch Hospital'}
class CACLocation
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Conversion

  ATTRIBUTES =
    %i[additional_information_for_patients created_on
       data_source deleted_on external_location_id geojson
       is_collecting_samples is_collecting_samples_by_appointment_only
       is_collecting_samples_for_others is_collecting_samples_onsite
       is_evaluating_symptoms is_evaluating_symptoms_by_appointment_only
       is_hidden is_ordering_tests
       is_ordering_tests_only_for_those_who_meeting_criteria
       is_processing_samples is_processing_samples_for_others
       is_processing_samples_onsite is_verified location_address_locality
       location_address_postal_code location_address_region
       location_address_street location_contact_phone_appointments
       location_contact_phone_covid location_contact_phone_main
       location_contact_url_covid_appointments location_contact_url_covid_info
       location_contact_url_covid_screening_tool
       location_contact_url_covid_virtual_visit
       location_contact_url_main location_hours_of_operation
       location_id location_latitude location_longitude location_name
       location_place_of_service_type location_specific_testing_criteria
       location_status raw_data record_id reference_publisher_of_criteria
       updated_on].freeze

  attr_accessor(*ATTRIBUTES)

  def self.dump
    TestSites::CAC.cac_data.each_with_object([]) do |json, locations|
      locations << CACLocation.new(json)
    end
  end


  def to_storepoint
    { address: location_address_street, name: location_name }
  end
end

# frozen_string_literal: true

require 'active_model'
require 'test_sites'

# Represents a CAC testing-location.
#
# @example
#   location = CACLocation.new(location_name: 'Tisch Hospital',
#                              location_address_street: '550 First Avenue')
#     => #<CACLocation>
# rubocop:disable Metrics/ClassLength
class CACLocation
  include ActiveModel::Model

  ATTRIBUTES =
    %i[arcgis_location additional_information_for_patients created_on
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
  CAC_TO_STOREPOINT_MAPPING = {
    location_name: :name, storepoint_description: :description,
    street: :address, city: :city,
    state: :state, zip: :postcode,
    storepoint_country: :country, location_contact_phone_covid: :phone,
    location_contact_url_main: :website, storepoint_email: :email,
    storepoint_mon: :monday, storepoint_tue: :tuesday,
    storepoint_wed: :wednesday, storepoint_thu: :thursday,
    storepoint_fri: :friday, storepoint_sat: :saturday, storepoint_sun: :sunday,
    location_place_of_service_type: :tags, storepoint_extra: :extra,
    location_latitude: :lat, location_longitude: :lng,
    location_hours_of_operation: :hours
  }.freeze

  attr_accessor(*ATTRIBUTES)
  attr_writer :componentized_us_address

  # Returns an array of CACLocations from the API.
  #
  # @return [Array] all CACLocations from the API
  def self.all_from_api
    geocoder_results = TestSites::GeocoderResults.new.filtered
    arcgis_locations = ArcGISClient.locations

    TestSites::CAC.cac_data.map do |mash|
      CACLocation.new(mash).tap do |location|
        add_arcgis_data_to_location(location, arcgis_locations)
        add_address_to_location(location, geocoder_results)
      end
    end
  end

  def self.add_address_to_location(location, geocoder_results)
    geocoder_result = geocoder_results[location.location_address_street]
    return unless geocoder_result

    location.componentized_us_address =
      TestSites::ComponentizedUSAddress.new(
        geocoder_results[location.location_address_street]
      )
  end

  def self.add_arcgis_data_to_location(location, arcgis_locations)
    location.arcgis_location = arcgis_locations[location.arcgis_global_id]
  end

  # Converts the specified array of CACLocations to an array of
  # StorepointLocations.
  #
  # @param locations [Array] the CACLocations to convert
  # @return [Array] StorepointLocations
  def self.to_storepoint(locations)
    locations.map(&:to_storepoint)
  end

  def address
    location_address_street
  end

  def street
    @componentized_us_address&.street || location_address_street
  end

  def city
    @componentized_us_address&.city || location_address_locality
  end

  def state
    @componentized_us_address&.state || location_address_region
  end

  def zip
    @componentized_us_address&.zip || location_address_postal_code
  end

  def storepoint_country; end

  def storepoint_description
    additional_information_for_patients
  end

  def storepoint_email; end

  def storepoint_extra; end

  def storepoint_fri; end

  def storepoint_mon; end

  def storepoint_sat; end

  def storepoint_sun; end

  def storepoint_thu; end

  def storepoint_tue; end

  def storepoint_wed; end

  def arcgis_global_id
    @arcgis_global_id ||=
      if external_location_id.present?
        global_id =
          JSON.parse(external_location_id).compact.find do |id|
            id['kind'] == 'esriFieldTypeGlobalID'
          end
        value = global_id && global_id['value']
        value&.gsub(/[^[[:alnum:]]|-]/, '')&.downcase
      end
  end

  # Returns a hash of attributes suitable for exporting to Storepoint.
  #
  # @return [Hash] this location's attributes in Storepoint format
  # @example
  #   location.to_storepoint
  #     => { address: '550 First Avenue', name: 'Tisch Hospital'... }
  def to_storepoint
    CAC_TO_STOREPOINT_MAPPING.each_with_object({}) do |fields, h|
      h[fields[1]] = send(fields[0])
    end
  end
end
# rubocop:enable Metrics/ClassLength

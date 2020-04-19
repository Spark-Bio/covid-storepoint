# frozen_string_literal: true

require 'active_model'
require 'test_sites'

# Represents a Storepoint testing-location, as seen on
# https://cdn.storepoint.co/map/15e8a21d28c6d0
#
# @example
#   location = StorepointLocation.new(name: 'Tisch Hospital',
#                                     address: '550 First Avenue')
#     => #<StorepointLocation>
class StorepointLocation
  include ActiveModel::Model

  ATTRIBUTES =
    %i[name description address city state postcode country phone website email
       monday tuesday wednesday thursday friday saturday sunday tags extra lat
       lng hours].freeze

  attr_accessor(*ATTRIBUTES)
end

# frozen_string_literal: true

require 'hashie'

module TestSites
  # This class represents a Hashie Mash that supresses warnings about
  # overridden methods.
  class NoWarningMash < Hashie::Mash
    disable_warnings
  end
end

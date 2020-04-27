# frozen_string_literal: true

require 'hashie'

module TestSites
  # This class represents a Hashie Mash that supresses warnings about
  # overridden methods.
  class NoWarningMash < Hashie::Mash
    disable_warnings

    def respond_to_missing?(method_name, *args)
      return false if method_name == :permitted?

      super
    end

    def method_missing(method_name, *args)
      raise ArgumentError if method_name == :permitted?

      super
    end
  end
end

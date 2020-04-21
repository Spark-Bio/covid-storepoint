# frozen_string_literal: true

require 'faraday'
require 'faraday/detailed_logger'
require 'faraday_middleware'

module TestSites
  DETAILED_LOGGING = ENV['DETAILED_API_LOGGING'] == 'true'
  DEFAULT_TIMEOUT = 180

  # Generic API client superclass
  class APIClient
    def initialize(endpoint)
      @connection = Faraday.new(url: endpoint) do |conn|
        conn.options[:timeout] = DEFAULT_TIMEOUT

        conn.request :json

        conn.response :mashify, mash_class: NoWarningMash
        conn.response :json, content_type: /\bjson$/
        conn.response :detailed_logger if DETAILED_LOGGING

        yield(conn) if block_given?

        conn.adapter Faraday.default_adapter
      end
    end

    def get(path, log_action)
      result = @connection.get path
      check_status(result, log_action)
      result.body
    end

    def post(path, data, log_action)
      result = @connection.post path, data
      check_status(result, log_action)
      result.body
    end

    private

    def check_status(result, log_action)
      return if result.status == 200

      raise "Error #{log_action}, status: #{result.status}" \
      " message: #{result.body}"
    end
  end
end

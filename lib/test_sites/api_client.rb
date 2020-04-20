# frozen_string_literal: true

require 'faraday'
require 'faraday/detailed_logger'
require 'faraday_middleware'

module TestSites
  DETAILED_LOGGING = ENV['DETAILED_API_LOGGING'] == 'true'
  DEFAULT_TIMEOUT = 180

  # Generaic API client superclass
  class APIClient
    def conn(endpoint)
      @conn ||=
        Faraday.new(url: endpoint) do |conn|
          conn.options[:timeout] = DEFAULT_TIMEOUT

          conn.request :json

          conn.response :mashify, mash_class: NoWarningMash
          conn.response :json, content_type: /\bjson$/
          conn.response :detailed_logger if DETAILED_LOGGING

          yield(conn) if block_given?

          conn.adapter Faraday.default_adapter
        end
    end

    def check_status(result, action)
      return if result.status == 200

      raise "Error #{action}, status: #{result.status}" \
      " message: #{result.body}"
    end

    def get(path, action)
      result = conn.get path
      check_status(result, action)
      result.body
    end

    def post(path, data, action)
      result = conn.post path, data
      check_status(result, action)
      result.body
    end
  end
end

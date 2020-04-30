# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  # Wrapper for results from geocoder API.
  class GeocoderResults
    GEOCODER_RESULTS_FILE = DataFile.path('geocoder_results.json')

    def update(new_results)
      updated = raw_results
      updated.successes = updated.successes.merge(new_results[:successes])
      updated.exceptions = updated.exceptions.merge(new_results[:exceptions])
      save_json(GEOCODER_RESULTS_FILE, updated)
    end

    def already_geocoded?(addr)
      already_geocoded.include?(addr)
    end

    def dump_error_results
      TestSites.logger.debug "\n*** Error results: #{error_results.size}\n"
      TestSites.logger.debug error_results.sort_by { |_k, v| v.size }
                                          .map { |(k, v)| "#{k} - (#{v.size})" }
                                          .join("\n")
      true
    end

    def already_geocoded
      @already_geocoded = raw_results.successes.keys +
                          raw_results.exceptions.keys
    end

    # Filter out geocoder results
    # rubocop:disable Metrics/MethodLength
    def filtered
      @filtered ||=
        Hashie::Mash.new(
          all_results.each_with_object({}) do |(address, geo_result_list), acc|
            if geo_result_list.empty?
              TestSites.logger.error "skipping bad address: #{address}"
              next
            end

            if geocoder_results_equal(geo_result_list)
              acc[address] = geo_result_list.first
            end
          end
        )
    end
    # rubocop:enable Metrics/MethodLength

    def all_results
      @all_results ||=
        begin
          raw_results[:successes].each_with_object({}) do |(address, result), h|
            h[address] = result.map { |a_result| GeocoderResult.new(a_result) }
          end
        end
    end

    def raw_results
      @raw_results ||= raw_file(GEOCODER_RESULTS_FILE)
    end

    def geocoder_results_equal(results)
      results.size == 1 || results[0].all_equal?(results[1..-1])
    end

    def error_results
      @error_results ||=
        Hashie::Mash.new(
          all_results.each_with_object({}) do |(k, _v), _acc|
            !filtered.keys.include?(k)
          end
        )
    end

    def raw_file(path)
      Hashie::Mash.new(JSON.parse(File.read(path)))
    end

    def save_json(file, obj)
      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(obj))
      end
    end
  end
end

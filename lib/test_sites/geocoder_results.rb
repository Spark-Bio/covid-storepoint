# frozen_string_literal: true

require 'csv'
require 'hashie'
require 'json'

module TestSites
  class GeocoderResults
    GEOCODER_RESULTS_FILE = DataFile.new('geocoder_results.json').to_s

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
      puts "\n*** Error results: #{error_results.size}\n"
      puts error_results.sort_by { |_k, v| v.size }.map { |(k, v)| "#{k} - (#{v.size})" }.join("\n")
      true
    end

    def already_geocoded
      @already_geocoded = raw_results.successes.keys + raw_results.exceptions.keys
    end

    # Filter out geocoder results
    def filtered
      @filtered ||=
        Hashie::Mash.new(
          all_results.each_with_object({}) do |(address, geo_result_list), acc|
            if geocoder_results_equal(geo_result_list)
              acc[address] = geo_result_list.first
            end
          end
        )
    end

    def all_results
      @all_results ||=
        begin
          raw_results[:successes].each_with_object({}) do |(address, raw_result), acc|
            acc[address] = raw_result.map { |single_result| GeocoderResult.new(single_result) }
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

    def save_json(f, obj)
      File.open(f, 'w') do |f|
        f.write(JSON.pretty_generate(obj))
      end
    end
  end
end

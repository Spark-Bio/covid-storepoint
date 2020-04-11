# frozen_string_literal: true

module TestSites
  class SourceDiff
    LATEST_RAW_SOURCE = DataFile.path('raw_sources/COVID 19 Updated.xlsx')

    def initialize; end

    def differences?
      added.any? || deleted.any?
    end

    def added
      available_only_in_first(source, latest_raw_source)
    end

    def deleted
      available_only_in_first(latest_raw_source, source)
    end

    def available_only_in_first(first, second)
      first.reject { |first_entry| second.primary_keys.include?(first_entry.primary_key) }
    end

    def source
      @source ||= Source.new
    end

    def latest_raw_source
      @latest_raw_source ||= Source.new(source_file: LATEST_RAW_SOURCE)
    end

    def list
      print '*** Added: '
      list_group(added)

      puts ''
      print '*** Deleted: '
      list_group(deleted)
    end

    def list_group(group)
      if group.any?
        puts group.size
        puts group.map(&:primary_key).join("\n")
      else
        puts 'group'
      end
    end
  end
end

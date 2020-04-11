# frozen_string_literal: true

module TestSites
  class SourceDiff
    LATEST_RAW_SOURCE = DataFile.path('raw_sources/COVID 19 Updated.xlsx')

    def initialize; end

    def differences?
      added.any? || deleted.any?
    end

    def added
      source.primary_keys - latest_raw_source.primary_keys
    end

    def deleted
      latest_raw_source.primary_keys - source.primary_keys
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
        puts group.join("\n")
      else
        puts 'group'
      end
    end
  end
end

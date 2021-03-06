# frozen_string_literal: true

module TestSites
  # Wrapper for capturing differences between location-data sources.
  class SourceDiff
    def initialize; end

    def differences?
      added.any? || deleted.any?
    end

    def added
      available_only_in_first(latest_raw_source, source)
    end

    def deleted
      available_only_in_first(source, latest_raw_source)
    end

    DiffEntry = Struct.new(:source_entry, :possible_matches)
    # rubocop:disable Style/MultilineBlockChain
    def available_only_in_first(first, second)
      first.reject do |first_entry|
        # Eliminate any entries from the first list for which
        # there's a corresponding entry with the same key
        # in the second.
        second.primary_keys.include?(first_entry.primary_key)
      end.map do |source_entry|
        possible_matches =
          second.entries.find_all do |second_entry|
            source_entry.state_and_name_match?(second_entry)
          end
        DiffEntry.new(source_entry, possible_matches)
      end
    end
    # rubocop:enable Style/MultilineBlockChain

    def source
      @source ||= Source.new(exclude_ignored: false)
    end

    def latest_raw_source
      @latest_raw_source ||= Source.new(source_file: latest_raw_source_file)
    end

    # Assume latest source file is the xlsx file in `data/raw_sources` with the
    # largest number of worksheets
    def latest_raw_source_file
      @latest_raw_source_file ||=
        Dir.glob(DataFile.path('raw_sources/*xlsx'))
           .max_by { |f| Xsv::Workbook.open(f).sheets.size }
    end

    def list
      print '*** Added: '
      list_group(added)

      TestSites.logger.debug ''
      print '*** Deleted: '
      list_group(deleted)
    end

    def list_group(group)
      if group.any?
        TestSites.logger.debug group.size
        TestSites.logger.debug group
          .map { |diff_entry| diff_entry.source_entry.primary_key }
          .join("\n")
      else
        TestSites.logger.debug 'none'
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def dump_additions
      CSV.open(DataFile.path('additions.csv'), 'wb') do |csv|
        csv << ['State', 'Name', 'Current Address', 'Possible Source Address']
        added.map do |added|
          source_entry = added.source_entry
          source_fields = [source_entry.state, source_entry.name,
                           source_entry.key_address]
          TestSites.logger.debug "** SOURCE: #{source_entry.primary_key}"
          if added.possible_matches.empty?
            csv << [*source_fields, '']
          else
            added.possible_matches.each do |possible_match|
              TestSites.logger.debug "...SOURCE: #{possible_match.primary_key}"
              csv << [*source_fields, possible_match.key_address]
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end

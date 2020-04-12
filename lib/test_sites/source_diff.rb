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

    DiffEntry = Struct.new(:source_entry, :possible_matches)
    def available_only_in_first(first, second)
      first.reject do |first_entry|
        second.primary_keys.include?(first_entry.primary_key)
      end.map do |source_entry|
        possible_matches =
          second.entries.find_all do |second_entry|
            source_entry.state_and_name_match?(second_entry)
          end
        DiffEntry.new(source_entry, possible_matches)
      end
    end

    def source
      @source ||= Source.new(exclude_ignored: false)
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
        puts group.map { |diff_entry| diff_entry.source_entry.primary_key }.join("\n")
      else
        puts 'none'
      end
    end

    def dump_additions
      CSV.open(DataFile.path('additions.csv'), 'wb') do |csv|
        csv << ['State', 'Name', 'Current Address', 'Possible Source Address']
        added.map do |added|
          source_entry = added.source_entry
          source_fields = [source_entry.state, source_entry.name, source_entry.key_address]
          puts "** SOURCE: #{source_entry.primary_key}"
          if added.possible_matches.empty?
            csv << [*source_fields, '']
          else
            added.possible_matches.each do |possible_match|
              puts "...SOURCE: #{possible_match.primary_key}"
              csv << [*source_fields, possible_match.key_address]
            end
          end
        end
      end
    end
  end
end

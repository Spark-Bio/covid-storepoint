# frozen_string_literal: true

module TestSites
  # Wrapper for files in ./data.
  class DataFile
    def self.path(data_dir_relative_path)
      DataFile.new(data_dir_relative_path).to_s
    end

    def initialize(filename)
      @data_file = File.join(data_dir, filename)
    end

    def file
      @data_file
    end

    def to_s
      file.to_s
    end

    def data_dir
      File.expand_path(
        File.join(
          __dir__,
          '../../data'
        )
      )
    end
  end
end

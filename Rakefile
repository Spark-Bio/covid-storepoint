# frozen_string_literal: true

load 'lib/test_sites.rb' unless defined?(TestSites)
require 'logger'

def self.timestamp(&block)
  TestSites.logger.info "Started at #{task.timestamp}..."
  yield
  TestSites.logger.info "Finished at #{task.timestamp}."
end

task default: :test

task :diff_sources do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::SourceDiff.new.list
  end
end

desc 'Export all CAC locations to Storepoint'
task :export_cac_as_storepoint do |task|
  timestamp do
    load 'lib/models.rb' unless defined?(CACLocation)
    sp_locations = CACLocation.to_storepoint(CACLocation.all_from_api)

    CSV.open(TestSites::DataFile.path('cac_as_storepoint.csv'), 'w',
             write_headers: true,
             headers: TestSites::StorePoint::HEADERS.join(',')) do |csv|
      sp_locations.each { |location| csv << location.values }
    end
  end
end

task :geocode do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::Geocoder.new.process(TestSites::Source.new)
  end
end

task :geocode_cac_locations do |task|
  timestamp do
    load 'lib/models.rb' unless defined?(TestSites)
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::Geocoder.new.process(CACLocation.all_from_api)
  end
end

desc 'Check that the hour listings in the source file all parse correctly'
task :check_hours do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::HourParser.new.check_all
  end
end

desc 'Check how many of the hour listings obtained from CAC parse correctly'
task :check_cac_hours do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::HourParser.new.check_all(
      hours_to_check: TestSites::CAC.all_hours
    )
  end
end

desc 'List duplicate addresses in source file'
task :list_dups do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    dups = TestSites::Source.new.dup_addresses
    logger.info dups.join("\n") unless dups.blank?
  end
end

desc 'Export source file as Storepoint CSV'
task :update_storepoint do |task|
  timestamp do
    Rake::Task['list_dups'].execute
    Rake::Task['check_hours'].execute
    Rake::Task['geocode'].execute
    TestSites::StorePoint.new.update
    logger.info "*** Updated #{TestSites::StorePoint::OUTPUT_FILE}"
  end
end

task :dump_additions do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::SourceDiff.new.dump_additions
  end
end

task :compare_cac do |task|
  timestamp do
    load 'lib/test_sites.rb' unless defined?(TestSites)
    TestSites::CAC.new.dump_matches
  end
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.warning = false
end

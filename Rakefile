# frozen_string_literal: true

require 'logger'

def self.logger
  @logger = Logger.new(STDOUT)
  @logger.level = ENV['LOG_LEVEL'].blank? ? Logger::ERROR : ENV['LOG_LEVEL']
  @logger
end

task default: :test

task :diff_sources do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::SourceDiff.new.list
end

desc 'Export all CAC locations to Storepoint'
task :export_cac_as_storepoint do
  load 'lib/models.rb' unless defined?(CACLocation)
  sp_locations = CACLocation.to_storepoint(CACLocation.all_from_api)

  CSV.open(TestSites::DataFile.path('cac_as_storepoint.csv'), 'w',
           write_headers: true,
           headers: TestSites::StorePoint::HEADERS.join(',')) do |csv|
    sp_locations.each { |location| csv << location.values }
  end
end

task :geocode do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::Geocoder.new.process(TestSites::Source.new)
end

task :geocode_cac_locations do
  load 'lib/models.rb' unless defined?(TestSites)
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::Geocoder.new.process(CACLocation.all_from_api)
end

desc 'Check that the hour listings in the source file all parse correctly'
task :check_hours do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::HourParser.new.check_all
end

desc 'Check how many of the hour listings obtained from CAC parse correctly'
task :check_cac_hours do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::HourParser.new.check_all(
    hours_to_check: TestSites::CAC.all_hours
  )
end

desc 'List duplicate addresses in source file'
task :list_dups do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  dups = TestSites::Source.new.dup_addresses
  logger.info dups.join("\n") unless dups.blank?
end

desc 'Export source file as Storepoint CSV'
task :update_storepoint do
  Rake::Task['list_dups'].execute
  Rake::Task['check_hours'].execute
  Rake::Task['geocode'].execute
  TestSites::StorePoint.new.update
  logger.info "*** Updated #{TestSites::StorePoint::OUTPUT_FILE}"
end

task :dump_additions do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::SourceDiff.new.dump_additions
end

task :compare_cac do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::CAC.new.dump_matches
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.warning = false
end

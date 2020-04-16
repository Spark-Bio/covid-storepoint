# frozen_string_literal: true

task :diff_sources do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::SourceDiff.new.list
end

task :geocode do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::Geocoder.new.process
end

desc 'Check with the hour listings in the source file all parse crrectly'
task :check_hours do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::HourParser.new.check_all
end

desc 'List duplicate addresses in source file'
task :list_dups do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  dups = TestSites::Source.new.dup_addresses
  puts "Duplicate addresses:\n" + (dups.empty? ? 'None' : dups.join("\n"))
end

task :update_storepoint do
  Rake::Task['list_dups'].execute
  Rake::Task['check_hours'].execute
  Rake::Task['geocode'].execute
  TestSites::StorePoint.new.update
  puts "*** Updated #{TestSites::StorePoint::OUTPUT_FILE}"
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

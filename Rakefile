# frozen_string_literal: true

task :geocode do
  load 'lib/test_sites.rb'
  TestSites::Geocoder.new.process
end

desc 'Check with the hour listings in the source file all parse crrectly'
task :check_hours do
  load 'lib/test_sites.rb'
  TestSites::HourParser.new.check_all
end

task :update_storepoint do
  Rake::Task['check_hours'].execute
  Rake::Task['geocode'].execute
  puts "*** Updating #{TestSites::StorePoint::OUTPUT_FILE}..."
  TestSites::StorePoint.new.update
  puts "*** Updated #{TestSites::StorePoint::OUTPUT_FILE}"
end

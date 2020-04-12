# frozen_string_literal: true

task :diff_sources do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  puts "any differences? #{TestSites::SourceDiff.new.list}"
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
  puts "*** Updating #{TestSites::StorePoint::OUTPUT_FILE}..."
  TestSites::StorePoint.new.update
  puts "*** Updated #{TestSites::StorePoint::OUTPUT_FILE}"
end

task :dump_additions do
  load 'lib/test_sites.rb' unless defined?(TestSites)
  TestSites::SourceDiff.new.dump_additions
end

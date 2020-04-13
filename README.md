# StorePoint COVID-19 Testing Sites

Utilities for generating a CSV file of COVID-19 testing sites in the format required by [StorePoint](https://storepoint.co/dashboard/help).

## Developer Instructions

### Setup

* [Install `rbenv`](https://github.com/rbenv/rbenv#installation)
* Install the specified ruby version: ``rbenv install `cat .ruby-version` ``
* Install `bundler`: `gem install bundler`
* Install dependencies `bundle install`
* Obtain Google API key and set in your environment as GOOGLE_API_KEY_COVID

### Running tests

`bundle exec rake test`

### Updating `data/store_point.csv`

`bundle exec rake update_storepoint`

### Updating dependencies

When pulling the latest from github, if `Gemfile.lock` has been updated, run `bundle update`.

### Running locally in irb

```
12:00:00 (master)$ irb
irb(main):001:0> load 'lib/test_sites.rb'
=> true
irb(main):002:0> TestSites::Listings.new.listings.size
=> 954
```

## Overview

### Data sources

The source data comes from [evive](https://www.evive.care/) and a [crowdsourced document](https://docs.google.com/spreadsheets/d/1svnaZ2UG_ryFr8jjqVx7ZVZksBue4EQUJ4dolMDJx70/edit#gid=0) in addition to in-house / manual updates.

[`data/current_source.csv`](data/current_source.csv) is currently maintained manually, and updated periodically from the two sources above. Data including addresses is manually adjusted so there's currently not a reliable way to map entries in this file back to the source data.

### Data Quality Issues

The data needs cleanup to be able to be placed into StorePoint's locator. The main issues are:

* duplication of data
* missing addresses, or non-address text in the address field
* addresses that don't geocode
* hours are entered as a single free-form text field, but StorePoint expects them to be separated by day of the week
* Single entries that should be multiple entries, e.g. "Kaiser test centers in California - call for locations"
* Multiple entries that should be single entries, e.g. separate entries for testing for adults & children at the same site. These don't really work on a map since they're at the exact same point, so it's better to combine into one entry and add the specifics about testing in the freeform description field.

These issues are currently handled through a combination of manual adjustments and scripts. For example, freeform hours are converted to the "day of week" format via a [parser](lib/test_sites/hour_parser.rb) with a variety of heuristics. Although it can handle a variety of inputs, manual adjustments are still sometimes made to match an existing handled format, rather than expanding the (already too complicated) parser.

### Geocoding

[Google Geocoding API](https://developers.google.com/maps/documentation/geocoding/start) results are stored in [geocoder_results.rb](lib/test_sites/geocoder_results.rb). Addresses that have already been seen are not re-geocoded. In some cases the results in this file have been modified by hand, e.g. by manually adding address components such as `street_number` or by modifying `latitude` / `longitude` to a more precise location for the testing site - for example, in a case where the site is in a parking lot of a larger facility.

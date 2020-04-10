# StorePoint Covid-19 Testing Sites

Utilities for generating a CSV file of Covid-19 testing sites in the format required by [StorePoint](https://storepoint.co/dashboard/help).

## Setup

* [Install `rbenv`](https://github.com/rbenv/rbenv#installation)
* Install the specified ruby version: ``rbenv install `cat .ruby-version` ``
* Install `bundler`: `gem install bundler`
* Install dependencies `bundle install`
* Obtain Google API key and set in your environment as `GOOGLE_API_KEY_COVID`

## Update `data/store_point.csv`

`bundle exec rake update_storepoint`

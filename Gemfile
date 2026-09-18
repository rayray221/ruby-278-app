# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.7.8"

# Web
gem "rails", "7.1.5.1"
gem "puma", "~> 6.4"
gem "rack", "~> 2.2"
gem "sinatra", "~> 3.2", require: false

# Rails stack coverage
gem "active_model_serializers", "~> 0.10.14"
gem "graphql", "~> 2.3.0"

# Datastores
gem "pg", "~> 1.5.6"
gem "mysql2", "~> 0.5.6"
gem "trilogy", "~> 2.8.1"
gem "mongo", "~> 2.19"
gem "redis", "~> 4.8.1"
gem "redis-client", "~> 0.22.2"
gem "dalli", "~> 3.2.8"
gem "lmdb", "~> 0.6.1"

# HTTP clients
gem "faraday", "~> 2.8.1"
gem "excon", "~> 0.109.0"
gem "ethon", "~> 0.16.0"
gem "ffi", "~> 1.16.3"
gem "http", "~> 5.1.1"
gem "httpclient", "~> 2.8.3"
gem "rest-client", "~> 2.1.0"
gem "koala", "~> 3.5.0"

# Jobs
gem "sidekiq", "~> 7.2.4"
gem "resque", "~> 2.6.0"
gem "que", "~> 2.3.0"
gem "delayed_job_active_record", "~> 4.1.8"

# Messaging
gem "bunny", "~> 2.22.0"
gem "ruby-kafka", "~> 1.5.0"
gem "rdkafka", ">= 0.12", "< 0.16"
gem "racecar", ">= 2.8", "< 2.11"

# AWS / concurrency
gem "aws-sdk-s3", "~> 1.143"
gem "concurrent-ruby", "~> 1.2.3"

# AMS 0.10 passes quirks_mode to JSON.generate; json 3.x removed that keyword
gem "json", "~> 2.7.0"

# rake is a Rails dependency; listed explicitly for coverage clarity
gem "rake", "~> 13.2"

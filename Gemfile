source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'
gem 'rails-html-sanitizer', '~> 1.3.0'

# TODO: sprockets 4.0.0 needs ruby >= 2.5.0
gem 'sprockets', '~> 3.7.2'

# JWS
gem 'prx_auth-rails', '~> 0.2.0'
gem 'rack-prx_auth', '~> 0.2.1'


## Model
# Use mysql as the database for Active Record
gem 'mysql2'

# ActiveRecord model additions
gem 'acts_as_list'
gem 'event_attribute'
gem 'paranoia', ' ~> 2.0'

# file uploads
gem 'carrierwave', '~> 0.11'
gem 'fog'
gem 'unf'

# hal api access
gem 'hyperresource'
gem 'oauth2'

# feed import
gem 'addressable'
gem 'excon'
gem 'faraday'
gem 'feedjira'
gem 'loofah'
gem 'nokogiri', '>= 1.8.1'

# Use Sanitize for HTML and CSS whitelisting
gem 'sanitize'

## Controller
gem 'hal_api-rails', '~> 0.3.3'
gem 'responders', '~> 2.0'

# auth
gem 'pundit'
gem 'rack-cors', require: 'rack/cors'

# paging
gem 'kaminari'

# caching
gem 'actionpack-action_caching'
gem 'dalli' # perhaps only production?

## View
# json handling
gem 'oj'
gem 'oj_mimic_json'
gem 'redcarpet'
gem 'reverse_markdown'
gem 'roar'
gem 'roar-rails'

## Messaging
gem 'announce'
gem 'say_when', '~> 2.x'
gem 'shoryuken', '~> 2.0.11'

## Deployment
# configuration
gem 'dotenv-rails'

# scripting
gem 'highline'
gem 'rake'

# monitoring
gem 'newrelic_rpm'

# elasticsearch
gem 'elasticsearch-dsl'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# production calendar
gem 'icalendar', '~> 2.5.0'

# dev-only
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard', '~> 2.10.0'
  gem 'guard-bundler'
  gem 'guard-minitest'
  gem 'quiet_assets'
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'minitest-around'
  gem 'minitest-reporters', require: false
  gem 'minitest-spec-rails'
  gem 'shoulda-context'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

group :development, :test do
  gem 'minitest', '~> 5.9.1'
  gem 'pry-byebug', '~> 3.4.1'
end

group :doc do
  gem 'sdoc', require: false
end

group :production, :staging do
  gem 'puma'
  gem 'rails_12factor'
end

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.10'
gem 'rails-html-sanitizer', '~> 1.0.4'

# JWS
gem 'prx_auth-rails', '~> 0.0.4'
gem 'rack-prx_auth', '~> 0.0.8'

## Model
# Use mysql as the database for Active Record
gem 'mysql2'
gem 'pg', '~> 0.19'

# ActiveRecord model additions
gem 'paranoia',' ~> 2.0'
gem 'acts_as_list'
gem 'event_attribute'

# file uploads
gem 'carrierwave', '~> 0.11'
gem 'fog'
gem 'unf'

# hal api access
gem 'oauth2'
gem 'hyperresource'

# feed import
gem 'feedjira'
gem 'addressable'
gem 'faraday'
gem 'excon'
gem 'loofah'
gem 'nokogiri', '>= 1.8.1'

# Use Sanitize for HTML and CSS whitelisting
gem 'sanitize'

## Controller
gem 'responders', '~> 2.0'
gem 'hal_api-rails', ' ~> 0.3.2'

# auth
gem 'rack-cors', require: 'rack/cors'
gem 'pundit'

# paging
gem 'kaminari'

# caching
gem 'dalli' # perhaps only production?
gem 'actionpack-action_caching'


## View
# json handling
gem 'roar'
gem 'roar-rails'
gem 'oj'
gem 'oj_mimic_json'
gem 'redcarpet'
gem 'reverse_markdown'

## Messaging
gem 'shoryuken', '~> 2.0.11'
gem 'announce'
gem 'say_when', '~> 2.x'

## Deployment
# configuration
gem 'dotenv-rails'

# scripting
gem 'capistrano', '~> 3.2'
gem 'capistrano-rails', '~> 1.1'
gem 'highline'
gem 'rake'
gem 'slackistrano', require: false

# monitoring
gem 'newrelic_rpm'
gem 'capistrano-newrelic'

# elasticsearch
gem 'elasticsearch-rails-ha'
gem 'elasticsearch-dsl'

# dev-only
group :development do
  gem 'web-console', '~> 2.0'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard', '~> 2.10.0'
  gem 'guard-minitest'
  gem 'guard-bundler'
  gem 'spring'
end

group :test do
  gem 'minitest-around'
  gem 'minitest-spec-rails'
  gem 'minitest-reporters', require: false
  gem 'factory_girl_rails'
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', require: false
  gem 'codecov', require: false
  gem 'webmock'
end

group :development, :test do
  gem 'pry-byebug', '~> 3.4.1'
  gem 'minitest', '~> 5.9.1'
end

group :doc do
  gem 'sdoc', require: false
end

group :production, :staging do
  gem 'makara'
  gem 'puma'
  gem 'rails_12factor'
end

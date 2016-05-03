source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.1'

# JWS
gem 'prx_auth-rails', '~> 0.0.4'
gem 'rack-prx_auth', '~> 0.0.8'

## Model
# Use mysql as the database for Active Record
gem 'mysql2'

# ActiveRecord model additions
gem 'paranoia',' ~> 2.0'
gem 'acts_as_list'
gem 'event_attribute'

# file uploads
gem 'carrierwave'
gem 'fog'
gem 'unf'

## Controller
gem 'responders', '~> 2.0'
gem 'hal_api-rails', '~> 0.2.3'

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

## Messaging
gem 'shoryuken'
gem 'announce'

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

# These will not be installed on travis - keep all
# developer-specific gems here so our travis builds
# stay snappy!
group :development do
  gem 'web-console', '~> 2.0'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'growl'
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
  gem "codeclimate-test-reporter", require: false
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'pry-rails'
end

group :doc do
  gem 'sdoc', require: false
end

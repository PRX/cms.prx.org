source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.0'

# JWS
gem 'json-jwt', '~> 0.7.0'
gem 'rack-prx_auth'

## Model
# Use mysql as the database for Active Record
gem 'mysql2'

# ActiveRecord model additions
gem 'paranoia'
gem 'acts_as_list'
gem 'event_attribute'

# file uploads
gem 'carrierwave'
gem 'fog'
gem 'unf'


## Controller
# auth
gem 'rack-cors', :require => 'rack/cors'

# paging
gem 'kaminari'

# caching
gem 'dalli' # perhaps only production?
gem 'actionpack-action_caching'

## View
# json handling
gem 'roar-rails'
gem 'oj'
gem 'oj_mimic_json'


## Deployment
# configuration
gem 'dotenv-rails'

# scripting
gem 'capistrano', '~> 3.2.0'
gem 'capistrano-rails', '~> 1.1.0'
gem 'highline'
gem 'rake'

# monitoring
gem 'newrelic_rpm'
gem 'capistrano-newrelic'

# These will not be installed on travis - keep all
# developer-specific gems here so our travis builds
# stay snappy!
group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'

  gem 'growl', require: false
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-bundler'
  gem 'spring'
end

group :test do
  gem 'minitest-spec-rails'
  gem 'minitest-reporters', require: false
  gem 'factory_girl_rails'
  gem "codeclimate-test-reporter", require: false
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'coveralls', require: false
end

group :doc do
  gem 'sdoc', require: false
end

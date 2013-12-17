source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Use mysql as the database for Active Record
gem 'mysql2'

gem 'roar-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'rake'
  gem 'minitest-rails'
  gem 'minitest-reporters', require: false
  gem 'factory_girl_rails'
  gem "codeclimate-test-reporter", require: false
end

# These will not be installed on travis - keep all
# developer-specific gems here so our travis builds
# stay snappy!
group :development do
  gem 'growl', require: false
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-bundler'
  gem 'spring'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

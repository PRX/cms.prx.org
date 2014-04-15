ENV["RAILS_ENV"] = "test"

require 'simplecov' if !ENV['GUARD'] || ENV['GUARD_COVERAGE']
if ENV['TRAVIS']
  require 'codeclimate-test-reporter'
  SimpleCov.formatter = Class.new(SimpleCov.formatter) do
    define_method :formatters do
      @formatters ||= super() + [CodeClimate::TestReporter::Formatter]
    end
  end
end

require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"
require 'factory_girl'
require "minitest/rails"
require "minitest/reporters"
require 'minitest/autorun'
require 'minitest/spec'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods

  def extract_filename(uri)
    URI.parse(uri).path.split('?')[0].split('/').last
  end

end

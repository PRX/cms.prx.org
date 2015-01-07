ENV["RAILS_ENV"] = "test"

require 'simplecov' if !ENV['GUARD'] || ENV['GUARD_COVERAGE']

if ENV['TRAVIS']
  require 'codeclimate-test-reporter'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov.formatter,
    Coveralls::SimpleCov::Formatter,
    CodeClimate::TestReporter::Formatter
  ]
end

require File.expand_path("../../config/environment", __FILE__)

require 'rails/test_help'
require 'factory_girl'
require 'minitest/reporters'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def api_request_opts(opts={})
    { format: 'json', api_version: 'v1' }.merge(opts)
  end
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods

  def extract_filename(uri)
    URI.parse(uri).path.split('?')[0].split('/').last
  end
end

Minitest::Expectations.infect_an_assertion :assert_operator, :must_allow, :reverse
Minitest::Expectations.infect_an_assertion :refute_operator, :wont_allow, :reverse

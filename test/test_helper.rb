ENV['RAILS_ENV'] = 'test'

ENV['PRX_HOST'] = 'www.prx.org'
ENV['CMS_HOST'] = 'cms.prx.org'
ENV['META_HOST'] = 'meta.prx.org'

require 'simplecov' if !ENV['GUARD'] || ENV['GUARD_COVERAGE']

ENV['action_dispatch.logger'] = Rails.logger

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
require 'announce'
require 'announce/testing'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Announce::Testing

  def api_request_opts(opts={})
    { format: 'json', api_version: 'v1' }.merge(opts)
  end
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods
  include Announce::Testing

  def extract_filename(uri)
    URI.parse(uri).path.split('?')[0].split('/').last
  end
end

Minitest::Expectations.infect_an_assertion :assert_operator, :must_allow, :reverse
Minitest::Expectations.infect_an_assertion :refute_operator, :wont_allow, :reverse

include Announce::Testing
reset_announce

StubToken = Struct.new(:resource, :scopes, :user_id)
class StubToken
  @@fake_user_id = 0

  def initialize(res, scopes, explicit_user_id = nil)
    if explicit_user_id
      super(res.to_s, scopes, explicit_user_id)
    else
      super(res.to_s, scopes, @@fake_user_id += 1)
    end
  end

  def authorized?(r, s = nil)
    resource == r.to_s && (s.nil? || scopes.include?(s.to_s))
  end
end

ENV['RAILS_ENV'] = 'test'

ENV['CMS_HOST'] = 'cms.prx.org'
ENV['FEEDER_HOST'] = 'feeder.prx.org'
ENV['ID_HOST'] = 'id.prx.org'
ENV['META_HOST'] = 'meta.prx.org'
ENV['PRX_HOST'] = 'beta.prx.org'
ENV['PRX_CLIENT_ID'] = '0123456789abcdefghijklmnopqrstuvwxyzABCD'
ENV['PRX_SECRET'] = '0123456789abcdefghijklmnopqrstuvwxyzABCD'

if !ENV['GUARD'] || ENV['GUARD_COVERAGE']
  require 'simplecov'
  require 'codecov'
  require 'codeclimate-test-reporter'
  formatters = [SimpleCov.formatter]
  formatters << SimpleCov::Formatter::Codecov if ENV['CODECOV_TOKEN']
  formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']
  SimpleCov.formatters = formatters
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
require 'webmock/minitest'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction

def use_webmock?
  ENV['USE_WEBMOCK'].nil? || (ENV['USE_WEBMOCK'] == 'true')
end
WebMock.allow_net_connect! unless use_webmock?
WebMock.disable_net_connect!(allow: /elasticsearch|9200/) if use_webmock?

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

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

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  ElasticsearchHelper.es_setup
end

Minitest::Expectations.infect_an_assertion :assert_operator, :must_allow, :reverse
Minitest::Expectations.infect_an_assertion :refute_operator, :wont_allow, :reverse

include Announce::Testing
reset_announce

StubToken = Struct.new(:resource, :scopes, :user_id)
class StubToken
  attr_accessor :authorized_resources, :attributes
  @@fake_user_id = 0

  def initialize(res, scopes, explicit_user_id = nil)
    @authorized_resources = { res => scopes }
    if explicit_user_id
      super(res.to_s, scopes, explicit_user_id)
    else
      super(res.to_s, scopes, @@fake_user_id += 1)
    end
  end

  def authorized?(r, s = nil)
    res = authorized_resources.keys
    roles = authorized_resources.values.flatten
    res.include?(r) && (s.nil? || roles.include?(s.to_s))
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :minitest
    # Choose one or more libraries:
    with.library :active_model
    # Or, choose the following (which implies all of the above):
    # with.library :rails
  end
end

def json_file(name)
  test_file("/fixtures/#{name}.json")
end

def test_file(path)
  File.read( File.dirname(__FILE__) + path)
end

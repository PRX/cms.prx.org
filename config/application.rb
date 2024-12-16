require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module PRX
  APP_VERSION = 'v4'.freeze

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    I18n.config.enforce_available_locales = true
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :en

    config.autoload_paths += %W( #{config.root}/app/representers/concerns )
    config.autoload_paths += %W( #{config.root}/app/workers )

    # Disable the asset pipeline.
    config.assets.enabled = false

    config.generators do |g|
      g.test_framework :mini_test, spec: true, fixture: false
    end

    config.middleware.insert_after Rails::Rack::Logger, Rack::Cors do
      allow do
        origins /.*\.prx\.(?:org|dev|test|tech|docker)$/
        resource '/api/*', methods: [:get, :put, :post, :delete, :options], headers: :any
      end

      allow do
        origins '*'
        resource '/api/*', methods: [:get]
      end

      allow do
        origins '*'
        resource '/pub/*', methods: [:get, :head, :options], headers: :any
      end
    end

    # explicitly set auth host, rather than defaulting to id.prx.org
    if ENV['ID_HOST'].present?
      protocol = ENV['ID_HOST'].include?('.docker') ? 'http' : 'https'
      config.middleware.insert_before 'ActionDispatch::ParamsParser', 'Rack::PrxAuth',
                                      cert_location: "#{protocol}://#{ENV['ID_HOST']}/api/v1/certs",
                                      issuer: ENV['ID_HOST']
    end

    config.active_job.queue_adapter = :shoryuken
    config.active_job.queue_name_prefix = ENV['ANNOUNCE_RESOURCE_PREFIX'] || ENV['RAILS_ENV']
    config.active_job.queue_name_delimiter = '_'

    config.active_record.raise_in_transactional_callbacks = true

    prx_url_options = { host: ENV['PRX_HOST'], protocol: 'https' }
    config.action_mailer.default_url_options = prx_url_options

    proto = (ENV['CMS_HOST'] || '').include?('.docker') ? 'http' : 'https'
    cms_url_options = { host: ENV['CMS_HOST'], protocol: proto }
    Rails.application.routes.default_url_options = cms_url_options

    # Logging
    require "#{Rails.root}/lib/cms_logger.rb"
    config.logger = ActiveSupport::TaggedLogging.new(CmsLogger.new($stdout))

    # Used when invoking the async workers via supervisord.
    if ENV['USE_SYNC_STDOUT'].present?
      $stdout.sync = true
    end

    config.lograge.enabled = true
    config.lograge.custom_payload do |controller|
      exclude = %w[controller action format id authenticity_token access_token id_token]
      {
        params: controller.request.params.except(*exclude),
        user_agent: controller.request.user_agent,
        user_id: Rails.env.test? ? nil : controller.try(:prx_auth_token)&.user_id&.to_i,
        user_ip: controller.request.ip,
        user_ref: controller.request.referrer
      }.compact
    end
    config.lograge.ignore_custom = lambda do |event|
      if event.payload[:path] == '/' && event.payload[:status] == 302
        true
      elsif event.payload[:path] == '/api/v1'
        true
      end
    end

    config.lograge.formatter = Class.new do |fmt|
      def fmt.call(data)
        {msg: 'Request', request: data.except('unpermitted_params')}.to_json
      end
    end

    # config.log_tags = [:request_id]
  end
end

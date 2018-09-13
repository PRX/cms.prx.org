require 'shoryuken'
require 'shoryuken/extensions/active_job_adapter'

# for older shoryuken, < 3.x, where celluloid is still used
require 'celluloid'
require 'say_when/processor/active_job_strategy'
require 'say_when/poller/celluloid_poller'

Shoryuken.on_start do
  SayWhen::Poller::CelluloidPoller.supervise_as(:say_when, 5)
end

Shoryuken.default_worker_options = {
  'queue'                   => "#{Rails.env}_cms_default",
  'auto_delete'             => true,
  'auto_visibility_timeout' => true,
  'batch'                   => false,
  'body_parser'             => :json
}

Shoryuken.configure_server do |_config|
  Rails.logger = Shoryuken::Logging.logger
  ActiveJob::Base.logger = Shoryuken::Logging.logger
  ActiveRecord::Base.logger = Shoryuken::Logging.logger
end

begin
  Shoryuken.configure_client do |_config|
    unless Rails.env.test?
      config_file = File.join(Rails.root, 'config', 'shoryuken.yml')
      Shoryuken::EnvironmentLoader.load(config_file: config_file)
      Shoryuken::Client.account_id = Shoryuken.options[:aws][:account_id] || ENV['AWS_ACCOUNT_ID']

      # LOCALSTACK
      Shoryuken.options[:sns_endpoint] = 'http://192.168.99.100:4575'
      Shoryuken.options[:sqs_endpoint] = 'http://192.168.99.100:4576'


    end
  end
rescue StandardError => err
  Rails.logger.error('*** Shoryuken client failed to initialize. ***')
  Rails.logger.error(err)
end



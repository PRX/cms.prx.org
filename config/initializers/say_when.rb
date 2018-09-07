require 'say_when'

# Specify a logger for SayWhen
SayWhen.logger = Rails.logger

# Configure the scheduler for how to store and process scheduled jobs
# it will default to a :memory strategy and :simple processor
SayWhen.configure do |options|
  options[:processor_strategy] = :active_job
  options[:queue] = :cms_default

  options[:storage_strategy] = :active_record
  options[:store_executions] = false
  options[:table_prefix] = 'cms_'
end

begin
  SayWhen.schedule(
    group: 'application',
    name: 'check_published',
    trigger_strategy: 'cron',
    trigger_options: { expression: '0 0/5 * * * ?', time_zone: 'UTC' },
    job_class: 'Distribution',
    job_method: 'check_published!'
  )
rescue ActiveRecord::StatementInvalid => ex
  puts "Failed to init say_when job: #{ex.inspect}"
end

begin
  SayWhen.schedule(
    group: 'application',
    name: 'reindex_stories',
    trigger_strategy: 'cron',
    trigger_options: { expression: '0 0 8 * * ? *', time_zone: 'UTC' },
    job_class: 'Story',
    job_method: 'rebuild_index'
  )
rescue ActiveRecord::StatementInvalid => ex
  puts "Failed to init say_when job: #{ex.inspect}"
end

begin
  SayWhen.schedule(
    group: 'application',
    name: 'reindex_series',
    trigger_strategy: 'cron',
    trigger_options: { expression: '0 0 7 * * ? *', time_zone: 'UTC' },
    job_class: 'Series',
    job_method: 'rebuild_index'
  )
rescue ActiveRecord::StatementInvalid => ex
  puts "Failed to init say_when job: #{ex.inspect}"
end

# # for use with Shoryuken >= 3.x
# require 'say_when/poller/concurrent_poller'
# poller = SayWhen::Poller::ConcurrentPoller.new(5)
# poller.start

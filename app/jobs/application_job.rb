require 'newrelic_rpm'

class ApplicationJob < ActiveJob::Base
  if ENV['DEFAULT_JOB_QUEUE_NAME']
    queue_as ENV['DEFAULT_JOB_QUEUE_NAME']
    self.queue_name_prefix = nil
  end

  rescue_from(StandardError) do |e|
    NewRelic::Agent.notice_error(e)
    raise e
  end

  around_perform do |job, block|
    ActiveRecord::Base.connection_pool.with_connection do
      block.call
    end
  end
end

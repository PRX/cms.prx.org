require 'newrelic_rpm'

class ApplicationJob < ActiveJob::Base
  queue_as ENV['SQS_DEFAULT_QUEUE_NAME']

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

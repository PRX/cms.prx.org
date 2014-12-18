# encoding: utf-8
require 'media_monster_client'

class Task < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :owner, polymorphic: true

  serialize :options, JSON
  serialize :result, JSON

  enum status: [:created, :working, :complete, :failed, :cancelled]

  def create_fixer_job
    job = MediaMonster::Job.new

    job.original    = options['original']
    job.job_type    = options['job_type']      || 'audio'
    job.retry_delay = options['retry_delay']   || 3600 # 1 hour
    job.retry_max   = options['retry_max']     || 24 # try for a whole day
    job.priority    = options['priority']      || 2
    job.call_back   = options['call_back_url'] || call_back_url

    job = MediaMonsterClient.create_job(job)
    self.identifier = job.id
    save!
  end

  def fixer_callback(params)
    logger.debug("fixer_callback: params: #{params.inspect}")
  end

  def call_back_url(mod=self)
    class_name = mod.class.name.demodulize.underscore
    Rails.application.routes.url_helpers.callback_url(action: 'fixer', class: class_name, id: mod.id)
  end
end

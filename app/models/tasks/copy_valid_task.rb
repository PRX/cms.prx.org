# encoding: utf-8

class Tasks::CopyValidTask < Task

  after_commit :create_job, :on => :create

  def create_copy_job
    fixer_job = create_fixer_job do |job|
      job.job_type    = 'audio'
      job.priority    = 1
      job.original    = original
      job.retry_delay = Task::RETRY_DELAY
      job.retry_max   = Task::MAX_WORKTIME / Task::RETRY_DELAY

      job.add_sequence do |seq|
        seq.add_task(task_type: 'validate', call_back: fixer_callback, label: id, options: audio_validate_options)
        seq.add_task(task_type: 'copy', result: destination, call_back: fixer_callback)
      end
    end
  end

end

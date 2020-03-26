class AudioCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownAudioTypeError < StandardError; end

  shoryuken_options AudioFile::CALLBACK_QUEUE

  def perform(_sqs_msg, job)
    if job['JobResult']
      porter_callback(job)
    else
      audio = AudioFile.find(job['id'])
      update_audio(audio, job)
    end
    story = audio.story
    story.with_lock do
      announce(:story, :update, Api::Msg::StoryRepresenter.new(story).to_json)
    end
  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  end

  def porter_callback(job)
    audio_file = AudioFile.find(audio_file_id(job))
    process_results(audio_file, job['JobResult']['TaskResults'])
    finish(audio_file)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def update_audio(audio, job)
    audio.filename = job['name']
    audio.size = job['size']
    audio.content_type = job['mime']

    # guess which stream we should look at - audio or video
    meta = job['audio'] || job['video'] || {}
    if job['video'] && audio.video?
      meta = job['video']
    end

    # set audio info from meta
    audio.length = (meta.fetch('duration', 0) / 1000.0).round
    audio.bit_rate = (meta.fetch('bitrate', 0) / 1000.0).round
    audio.frequency = meta.fetch('frequency', 0) / 1000.0

    # fallback to guessing layer from the format string (mp2 / mp3 / etc)
    format_layer = meta.fetch('format', '').match(/mp(\d)/).try(:[], 1).to_i
    audio.layer = meta.fetch('layer', nil) || format_layer

    # TODO: not quite sure how to get this from ffprobe
    # job['channels'] = ffmpeg.channels
    # job['layout'] = ffmpeg.channel_layout
    audio.channel_mode = if meta['channels'] == 2
                           STEREO
                         elsif meta['channels'] == 1
                           SINGLE_CHANNEL
                         end

    # set errors - content type validation happens in the AudioVersionTemplate
    if !job['downloaded']
      audio.status = NOTFOUND
      audio.status_message = job['error'] || error_message('downloading', audio)
    elsif !job['processed']
      audio.status = FAILED
      audio.status_message = job['error'] || error_message('processing', audio)
    elsif job['error']
      audio.status = FAILED
      audio.status_message = job['error']
    else
      audio.status = TRANSFORMED
      audio.status_message = nil
    end

    finish(audio)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

  private

  def finish(audio)
    # save and announce the audio changes on its story
    end_state = if audio.status_message
                  "#{audio.status} => #{audio}"
                else
                  audio.status
                end
    Shoryuken.logger.info("Updating AudioFile[#{audio.id}]: status => #{end_state}")
    audio.save!
  end

  def error_message(label, audio)
    "Error #{label} file #{audio.label || audio.id}"
  end

  def process_inspect_result(audio_file, inspect_result)
    if inspect_result.present?
      inspect_result = inspect_result['Inspection']
      audio_file.size = inspect_result['Size']
      audio_file.content_type = inspect_result['MIME']
      meta = priority_meta(inspect_result)
      # set audio/video info from meta
      audio_file.length = (meta.fetch('Duration', 0) / 1000.0).round
      audio_file.bit_rate = (meta.fetch('Bitrate', 0) / 1000.0).round

      process_audio_only_meta(inspect_result['Audio'] || {})
    end
  end

  def mode_for_channels(channels)
    case channels
    when 2 then STEREO
    when 1 then SINGLE_CHANNEL
    end
  end

  def priority_meta(inspect_result)
    if inspect_result['Video'].present? && audio_file.video?
      inspect_result['Video']
    else
      inspect_result['Audio'] || {}
    end
  end

  def process_audio_only_meta(audio_meta)
    audio_file.frequency = audio_meta.fetch('Frequency', 0) / 1000.0
    audio_file.layer = audio_meta.fetch('Layer', nil)
    audio_file.channel_mode = mode_for_channels(audio_meta['Channels'])
  end

  def set_status(audio_file, copy_result, inspect_result)
    if copy_result.nil?
      audio_file.status = NOTFOUND
      audio_file.status_message = error_message('downloading', audio)
    elsif inspect_result.nil?
      audio_file.status = FAILED
      audio_file.status_message = error_message('processing', audio)
    else
      audio_file.status = TRANSFORMED
      audio_file.status_message = nil
    end
  end

  def audio_file_id(job)
    job['Job']['Id'].split(':').last
  end

  def process_results(audio_file, task_results)
    copy_result = task_results.detect { |result| result['Task'] == 'Copy' }
    audio_file.filename = File.basename(copy_result['ObjectKey']) if copy_result.present?

    inspect_result = task_results.detect { |result| result['Task'] == 'Inspect' }
    process_inspect_result(audio_file, inspect_result)

    set_status(audio_file, copy_result, inspect_result)
  end
end

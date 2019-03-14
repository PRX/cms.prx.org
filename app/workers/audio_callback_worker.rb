class AudioCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownAudioTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_audio_callback"

  def perform(_sqs_msg, job)
    audio = AudioFile.find(job['id'])
    update_audio(audio, job)
    story = audio.story
    story.with_lock do
      announce(:story, :update, Api::Msg::StoryRepresenter.new(story).to_json)
    end

  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  end

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

    # save and announce the audio changes on its story
    end_state = audio.status_message ? "#{audio.status} => #{audio}" : audio.status
    Shoryuken.logger.info("Updating #{job['type']}[#{audio.id}]: status => #{end_state}")
    audio.save!
  end

  private

  def error_message(label, audio)
    "Error #{label} file #{audio.label || audio.id}"
  end
end

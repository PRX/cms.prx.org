class AudioCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownAudioTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_audio_callback"

  def perform(_sqs_msg, job)
    audio = AudioFile.find(job['id'])
    audio.filename = job['name']
    audio.size = job['size']
    audio.content_type = job['mime']

    # guess which stream we should look at - audio or video
    meta = job['audio'] || job['video'] || {}
    if job['video'] && audio.content_type.try(:starts_with?, 'video/')
      meta = job['video']
    end

    # set audio info from meta
    audio.length = (meta.fetch('duration', 0) / 1000.0).round
    audio.bit_rate = (meta.fetch('bitrate', 0) / 1000.0).round
    audio.frequency = meta.fetch('frequency', 0) / 1000.0
    audio.layer = meta.fetch('format', '').match(/mp(\d)/).try(:[], 1).to_i

    # TODO: not quite sure how to get this from ffprobe
    # job['channels'] = ffmpeg.channels
    # job['layout'] = ffmpeg.channel_layout
    audio.channel_mode = if meta['channels'] == 2
                           STEREO
                         elsif meta['channels'] == 1
                           SINGLE_CHANNEL
                         end

    # set errors but ignore valid/invalid status (will be determined later)
    if !job['downloaded']
      audio.status = NOTFOUND
      audio.status_message = job['error'] ||
                             "Error downloading file for #{audio.label || audio.id}"
    elsif !job['processed']
      audio.status = FAILED
      audio.status_message = job['error'] ||
                             "Error processing file #{audio.label || audio.id}"
    else
      audio.upload_path = nil
      audio.status = TRANSFORMED
      audio.status_message = nil
    end

    # save and announce the audio changes on its story
    end_state = audio.status_message ? "#{audio.status} => #{audio}" : audio.status
    Shoryuken.logger.info("Updating #{job['type']}[#{audio.id}]: status => #{end_state}")
    audio.save!
    announce(:story, :update, Api::Msg::StoryRepresenter.new(audio.story).to_json)

  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  end
end

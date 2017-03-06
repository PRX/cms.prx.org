class AudioCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownAudioTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_audio_callback"

  def perform(_sqs_msg, job)
    audio = AudioFile.find(job['id'])
    audio.filename = job['name']
    audio.length = job['duration']
    audio.size = job['size']
    audio.bit_rate = (job['bitrate'] || 0) / 1000
    audio.frequency = (job['frequency'] || 0) / 1000.0

    # decode content type and mpeg layer from basic "format" string
    mime_types = MIME::Types.type_for(job['format'] || '').map(&:to_s)
    prefer_type = mime_types.find { |t| t.starts_with?('audio') }
    audio.content_type = prefer_type || mime_types.first || job['format']

    # get layer from mp2/3/4 format string
    audio.layer = (job['format'] || '').match(/mp(\d)/).try(:[], 1).to_i

    # TODO: not quite sure how to get this from ffprobe
    # job['channels'] = ffmpeg.channels
    # job['layout'] = ffmpeg.channel_layout
    audio.channel_mode = if job['channels'] == 2
                           STEREO
                         elsif job['channels'] == 1
                           SINGLE_CHANNEL
                         end
    if !job['downloaded']
      audio.status = NOTFOUND
    elsif !job['valid'] || !job['processed']
      audio.status = FAILED
    else
      audio.upload_path = nil
      audio.status = TRANSFORMED
    end

    Shoryuken.logger.info("Updating #{job['type']}[#{audio.id}]: status => #{audio.status}")
    audio.save!
    # announce the audio changes on its story.
    announce(:story, :update, Api::StoryRepresenter.new(audio.story).to_json)

  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  end
end

require 'test_helper'

describe AudioCallbackWorker do

  let(:worker) { AudioCallbackWorker.new }
  let(:audio) { create(:audio_file_uploaded) }

  before(:all) do
    audio.story = create(:story)
  end

  before(:each) do
    Shoryuken::Logging.logger.level = Logger::FATAL
    clear_messages
  end

  after(:each) { Shoryuken::Logging.logger.level = Logger::INFO }

  def perform(attrs = {})
    defaults = {
      id: audio.id,
      name: 'test.mp3',
      size: 1234,
      mime: 'audio/mpeg',
      downloaded: true,
      valid: true,
      processed: true,
      error: nil,
    }
    worker.perform(nil, defaults.merge(attrs).with_indifferent_access)
    audio.reload
  end

  it 'updates audio file attributes' do
    meta = {duration: 11800, format: 'mp3', bitrate: 128000, frequency: 44100, channels: 2, layout: 'stereo'}
    perform(audio: meta)
    audio.filename.must_equal 'test.mp3'
    audio.length.must_equal 12
    audio.size.must_equal 1234
    audio.content_type.must_equal 'audio/mpeg'
    audio.layer.must_equal 3
    audio.bit_rate.must_equal 128
    audio.frequency.must_equal 44.1
    audio.channel_mode.must_equal(AudioCallbackWorker::STEREO)
  end

  it 'updates video file attributes' do
    audio_meta = {duration: 11800, bitrate: 128000}
    video_meta = {duration: 14040, bitrate: 196000}
    perform(audio: audio_meta, video: video_meta)
    audio.length.must_equal 12
    audio.bit_rate.must_equal 128
    perform(audio: audio_meta, video: video_meta, mime: 'video/mpeg')
    audio.length.must_equal 14
    audio.bit_rate.must_equal 196
  end

  it 'sets the status to point at the final audio file' do
    AudioFile.stub(:find, audio) do
      audio.stub(:set_status, true) do
        perform(name: 'foo.bar')
        audio.filename.must_equal 'foo.bar'
        audio.upload_path.must_be_nil
        audio.status.must_equal AudioCallbackWorker::TRANSFORMED
        audio.fixerable_final?.must_equal true
      end
    end
  end

  it 'rescues from non-existent audio ids' do
    perform(id: 99999, size: 12)
    audio.size.must_be_nil
  end

  it 'sets download errors' do
    perform(downloaded: false, error: 'something')
    audio.status.must_equal AudioCallbackWorker::NOTFOUND
    audio.status_message.must_equal 'something'
    audio.fixerable_final?.must_equal false
  end

  it 'sets processing errors' do
    perform(processed: false)
    audio.status.must_equal AudioCallbackWorker::FAILED
    audio.status_message.must_match 'Unable to process audio file'
    audio.fixerable_final?.must_equal false
  end

  it 'announces audio updates with story as resource' do
    perform(name: 'foo.bar')
    last_message.wont_be_nil
    last_message['subject'].must_equal :story
    last_message['action'].must_equal :update
    JSON.parse(last_message['body'])['id'].must_equal audio.story.id
  end

  it 'triggers template validations chain before save' do
    audio.story.status = nil
    audio.audio_version.status = nil
    perform(name: 'foo.bar')
    audio.story.status.wont_be_nil
    audio.audio_version.wont_be_nil
    JSON.parse(last_message['body'])['status'].wont_be_nil
  end
end

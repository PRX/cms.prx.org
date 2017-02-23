require 'test_helper'

describe AudioCallbackWorker do

  let(:worker) { AudioCallbackWorker.new }
  let(:audio) { FactoryGirl.create(:audio_file_uploaded) }

  before(:each) { Shoryuken::Logging.logger.level = Logger::FATAL }
  after(:each) { Shoryuken::Logging.logger.level = Logger::INFO }

  # {
  #   "id":987654,
  #   "path":"public/audio_files/987654",
  #   "name":"test_file.mp3",
  #   "duration":1045,
  #   "size":16705871,
  #   "format":"mp3",
  #   "bitrate":128000,
  #   "frequency":44100,
  #   "channels":2,
  #   "layout":"stereo",
  #   "downloaded":true,
  #   "valid":true,
  #   "processed":true
  # }

  def perform(attrs = {})
    defaults = {
      id: audio.id,
      downloaded: true,
      valid: true,
      processed: true
    }
    worker.perform(nil, defaults.merge(attrs).with_indifferent_access)
    audio.reload
  end

  it 'updates audio file attributes' do
    perform(name: 'foo.bar', duration: 12, size: 1234, format: 'mp2', bitrate: 128000,
            frequency: 44100, channels: 2, layout: 'stereo')
    audio.filename.must_equal 'foo.bar'
    audio.length.must_equal 12
    audio.size.must_equal 1234
    audio.content_type.must_equal 'audio/mpeg'
    audio.layer.must_equal 2
    audio.bit_rate.must_equal 128
    audio.frequency.must_equal 44.1
    audio.channel_mode.must_equal(AudioFile::STEREO)
  end

  it 'sets the status to point at the final audio file' do
    perform(name: 'foo.bar')
    audio.filename.must_equal 'foo.bar'
    audio.upload_path.must_be_nil
    audio.status.must_equal AudioFile::COMPLETE
    audio.fixerable_final?.must_equal true
  end

  it 'decodes audio mime-types' do
    perform(format: 'mp2')
    audio.content_type.must_equal 'audio/mpeg'
    perform(format: 'mp3')
    audio.content_type.must_equal 'audio/mpeg'
    perform(format: 'wav')
    audio.content_type.must_equal 'audio/x-wav'
  end

  it 'rescues from unknown audio types' do
    perform(format: 'foobar')
    audio.content_type.must_equal 'foobar'
    perform(format: 'audio/basic')
    audio.content_type.must_equal 'audio/basic'
  end

  it 'rescues from non-existent audio ids' do
    perform(id: 99999, size: 12)
    audio.size.must_be_nil
  end

  it 'sets download errors' do
    perform(downloaded: false)
    audio.status.must_equal AudioCallbackWorker::NOTFOUND
    audio.fixerable_final?.must_equal false
  end

  it 'sets validation errors' do
    perform(valid: false)
    audio.status.must_equal AudioCallbackWorker::INVALID
    audio.fixerable_final?.must_equal false
  end

  it 'sets processing errors' do
    perform(processed: false)
    audio.status.must_equal AudioCallbackWorker::FAILED
    audio.fixerable_final?.must_equal false
  end

end

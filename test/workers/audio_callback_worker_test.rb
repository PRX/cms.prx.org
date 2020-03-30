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
      detected: true,
      processed: true,
      error: nil,
    }
    worker.perform(nil, defaults.merge(attrs).with_indifferent_access)
    audio.reload
  end

  it 'updates audio file attributes' do
    meta = { duration: 11800, format: 'mp3', bitrate: 128000, frequency: 44100,
             channels: 2, layout: 'stereo' }
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

  it 'gets an explicit mpeg layer' do
    meta = { format: 'mp3', layer: 5 }
    perform(audio: meta)
    audio.layer.must_equal 5
  end

  it 'updates video file attributes' do
    audio_meta = { duration: 11800, bitrate: 128000 }
    video_meta = { duration: 14040, bitrate: 196000 }
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
        audio.upload_path.wont_be_nil
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

  it 'ignores detection errors' do
    perform(detected: false)
    audio.status.must_equal AudioCallbackWorker::COMPLETE
    audio.status_message.must_be_nil
    audio.fixerable_final?.must_equal true
  end

  it 'sets processing errors' do
    perform(processed: false)
    audio.status.must_equal AudioCallbackWorker::FAILED
    audio.status_message.must_match 'Error processing file'
    audio.fixerable_final?.must_equal false
  end

  it 'sets callback error messages' do
    perform(error: 'any error message')
    audio.status.must_equal AudioCallbackWorker::FAILED
    audio.status_message.must_equal 'any error message'
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

  describe 'with porter callback' do
    let (:successful_task_results) do
      [
        {
          'Task' => 'Copy',
          'Mode' => 'AWS/S3',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'foo/test2.mp3',
          'Time' => '2020-03-18T13:27:42.115Z',
          'Timestamp' => 1584538062.115
        },
        {
          'Task' => 'Inspect',
          'Inspection' => {
            'Size' => 46558797,
            'Audio' => {
              'Duration' => 2899827,
              'Format' => 'mp3',
              'Bitrate' => '128000',
              'Frequency' => '44100',
              'Channels' => 2,
              'Layout' => 'stereo',
              'Layer' => '3',
              'Samples' => nil,
              'Frames' => '111010'
            },
            'Extension' => 'mp3',
            'MIME' => 'audio/mpeg'
          }
        }
      ]
    end

    def callback_message(job_id, task_results)
      {
        'Time' => '2020-03-26T15:18:49.859Z',
        'Timestamp' => 1585235929.859,
        'JobResult' => {
          'Job' => {
            'Id' => job_id
          },
          'Execution' => {
            'Id' => 'arn:aws:states:us-east-1:asdfsadf'
          },
          'TaskErrors' => [],
          'JobError' => false,
          'TaskResults' => task_results
        }
      }
    end

    def perform_callback
      worker.perform(nil, callback_message(audio.to_global_id.to_s, successful_task_results))
      audio.reload
    end

    it 'updates audio file attributes' do
      perform_callback
      audio.filename.must_equal 'test2.mp3'
      audio.length.must_equal 2900
      audio.size.must_equal 46558797
      audio.content_type.must_equal 'audio/mpeg'
      audio.layer.must_equal 3
      audio.bit_rate.must_equal 128
      audio.frequency.must_equal 44.1
      audio.channel_mode.must_equal(AudioCallbackWorker::STEREO)
    end

    it 'gets an explicit mpeg layer' do
      successful_task_results[1]['Inspection']['Audio']['Layer'] = '5'

      perform_callback
      audio.layer.must_equal 5
    end

    it 'updates video file attributes' do
      successful_task_results[1]['Inspection'] = {
        'Size' => 16996018,
        'Audio' => {
          'Duration' => 158035,
          'Format' => 'aac',
          'Bitrate' => '109507',
          'Frequency' => '44100',
          'Channels' => 2,
          'Layout' => 'stereo'
        },
        'Video' => {
          'Duration' => 220000,
          'Format' => 'h264',
          'Bitrate' => '747441',
          'Width' => 640,
          'Height' => 360,
          'Aspect' => '16:9',
          'Framerate' => '24000/1001'
        },
        'Extension' => 'mp4',
        'MIME' => 'audio/mp4'
      }
      perform_callback
      audio.length.must_equal 158
      audio.bit_rate.must_equal 110

      successful_task_results[1]['Inspection']['MIME'] = 'video/mp4'
      perform_callback
      audio.length.must_equal 220
      audio.bit_rate.must_equal 747
    end

    it 'sets the status to point at the final audio file' do
      AudioFile.stub(:find, audio) do
        audio.stub(:set_status, true) do
          perform(name: 'foo.bar')
          audio.filename.must_equal 'foo.bar'
          audio.upload_path.wont_be_nil
          audio.status.must_equal AudioCallbackWorker::TRANSFORMED
          audio.fixerable_final?.must_equal true
        end
      end
    end

    it 'rescues from non-existent audio ids' do
      worker.perform(nil, callback_message(AudioFile.new(id:999).to_global_id.to_s, successful_task_results))
      audio.reload
      audio.size.must_be_nil
    end

    it 'sets download errors' do
      successful_task_results.delete_at(0)
      perform_callback
      audio.status.must_equal AudioCallbackWorker::NOTFOUND
      audio.status_message.must_match /Error downloading/
      audio.fixerable_final?.must_equal false
    end

    it 'ignores detection errors' do
      successful_task_results.delete_at(1)
      perform_callback
      audio.status.must_equal AudioCallbackWorker::COMPLETE
      audio.status_message.must_be_nil
      audio.fixerable_final?.must_equal true
    end

    it 'announces audio updates with story as resource' do
      perform_callback
      last_message.wont_be_nil
      last_message['subject'].must_equal :story
      last_message['action'].must_equal :update
      JSON.parse(last_message['body'])['id'].must_equal audio.story.id
    end

    it 'triggers template validations chain before save' do
      audio.story.status = nil
      audio.audio_version.status = nil
      perform_callback
      audio.story.status.wont_be_nil
      audio.audio_version.wont_be_nil
      JSON.parse(last_message['body'])['status'].wont_be_nil
    end

  end
end

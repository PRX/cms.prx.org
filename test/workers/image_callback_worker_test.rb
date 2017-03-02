require 'test_helper'

describe ImageCallbackWorker do

  let(:worker) { ImageCallbackWorker.new }
  let(:image) { create(:story_image_uploaded) }
  let(:series_image) { create(:series_image) }

  before(:each) do
    Shoryuken::Logging.logger.level = Logger::FATAL
    clear_messages
  end

  after(:each) { Shoryuken::Logging.logger.level = Logger::INFO }

  def perform(attrs = {})
    defaults = {
      id: image.id,
      type: image.class.table_name,
      downloaded: true,
      valid: true,
      resized: true
    }
    worker.perform(nil, defaults.merge(attrs).with_indifferent_access)
    image.reload
  end

  it 'updates image attributes' do
    perform(name: 'foo.bar', size: 12, width: 200, height: 160)
    image.filename.must_equal 'foo.bar'
    image.size.must_equal 12
    image.width.must_equal 200
    image.height.must_equal 160
    image.aspect_ratio.must_equal 1.25
  end

  it 'sets the status to point at the final image' do
    perform(name: 'foo.bar')
    image.filename.must_equal 'foo.bar'
    image.upload_path.must_be_nil
    image.status.must_equal Image::COMPLETE
    image.fixerable_final?.must_equal true
  end

  it 'decodes image mime-types' do
    perform(format: 'gif')
    image.content_type.must_equal 'image/gif'
  end

  it 'rescues from unknown image types' do
    perform(format: 'foobar')
    image.content_type.must_equal 'foobar'
    perform(format: 'image/jpg')
    image.content_type.must_equal 'image/jpg'
  end

  it 'rescues from non-existent image ids' do
    perform(id: 99999, size: 12)
    image.size.must_be_nil
  end

  it 'sets download errors' do
    perform(downloaded: false)
    image.status.must_equal ImageCallbackWorker::NOTFOUND
    image.fixerable_final?.must_equal false
  end

  it 'sets validation errors' do
    perform(valid: false)
    image.status.must_equal ImageCallbackWorker::INVALID
    image.fixerable_final?.must_equal false
  end

  it 'sets resize errors' do
    perform(resized: false)
    image.status.must_equal ImageCallbackWorker::FAILED
    image.fixerable_final?.must_equal false
  end

  it 'announces story updates for story-image' do
    perform(name: 'foo.bar')
    last_message.wont_be_nil
    last_message['subject'].must_equal :story
    last_message['action'].must_equal :update
    JSON.parse(last_message['body'])['id'].must_equal image.story.id
  end

  it 'announces series updates for series-image' do
    perform(name: 'foo.bar', id: series_image.id, type: series_image.class.table_name)
    last_message.wont_be_nil
    last_message['subject'].must_equal :series
    last_message['action'].must_equal :update
    JSON.parse(last_message['body'])['id'].must_equal series_image.series.id
  end
end

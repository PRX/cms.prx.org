require 'test_helper'

describe ImageCallbackWorker do

  let(:worker) { ImageCallbackWorker.new }
  let(:image) { FactoryGirl.create(:story_image_uploaded) }

  before(:each) { Shoryuken::Logging.logger.level = Logger::FATAL }
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
    image.status.must_equal Image::NOTFOUND
    image.fixerable_final?.must_equal false
  end

  it 'sets validation errors' do
    perform(valid: false)
    image.status.must_equal Image::INVALID
    image.fixerable_final?.must_equal false
  end

  it 'sets resize errors' do
    perform(resized: false)
    image.status.must_equal Image::FAILED
    image.fixerable_final?.must_equal false
  end

end

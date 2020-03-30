require 'test_helper'
require 'json'

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
    image.upload_path.wont_be_nil
    image.status.must_equal Image::COMPLETE
    image.fixerable_final?.must_equal true
  end

  it 'decodes image mime-types' do
    perform(name: 'foo.gif', format: 'gif')
    image.content_type.must_equal 'image/gif'
  end

  it 'rescues from unknown image types' do
    perform(name: 'foo.foobar', format: 'foobar')
    image.content_type.must_equal 'foobar'
    perform(name: 'foo.jpg', format: 'image/jpg')
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

  describe 'with porter callbacks' do

    let (:successful_task_results) do
      [
        {
          'Task' => 'Copy',
          'Mode' => 'AWS/S3',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/if3i36p9ok7bv9lygcih.jpeg',
          'Time' => '2020-03-18T13:27:42.115Z',
          'Timestamp' => 1584538062.115
        },
        {
          'Task' => 'Inspect',
          'Inspection' => {
            'Size' => 71484,
            'Audio' => {},
            'Image' => {
              'Width' => 450,
              'Height' => 450,
              'Format' => 'jpeg'
            },
            'Extension' => 'jpg',
            'MIME' => 'image/jpeg'
          }
        },
        {
          'Task' => 'Image',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/ex_square.jpeg',
          'Time' => '2020-03-18T13:27:42.021Z',
          'Timestamp' => 1584538062.021
        },
        {
          'Task' => 'Image',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/ex_small.jpeg',
          'Time' => '2020-03-18T13:27:42.021Z',
          'Timestamp' => 1584538062.021
        }, {
          'Task' => 'Image',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/ex_medium.jpeg',
          'Time' => '2020-03-18T13:27:42.021Z',
          'Timestamp' => 1584538062.021
        }
      ]
    end

    def porter_job_result(image, result)
      {
        'Time' => '2020-03-18T13:27:45.855Z',
        'Timestamp' => 1584538065.855,
        'JobResult' => {
          'Job' => {
            'Id' => image.porter_job_id
          },
          'Execution' => {
            'Id' => 'arn:aws:states:us-east-1:561178107736:execution:StateMachine-8B8z7vHLT4JS:etc'
          },
          'TaskResults' => Array.wrap(result)
        }
      }
    end

    def perform_porter_callback(use_image = image)
      results = if block_given?
                  yield
                else
                  successful_task_results
                end
      worker.perform(nil, porter_job_result(use_image, results))
      use_image.reload
      use_image
    end

    let(:image) { create(:story_image_uploaded, porter_job_id: SecureRandom.uuid) }
    let(:series_image) { create(:series_image, porter_job_id: SecureRandom.uuid) }

    it 'updates image attributes' do
      perform_porter_callback
      image.size.must_equal 71484
      image.width.must_equal 450
      image.height.must_equal 450
      image.aspect_ratio.must_equal 1
      image.content_type.must_equal 'image/jpeg'
    end

    it 'sets the status to point at the final image' do
      perform_porter_callback
      image.filename.must_equal 'if3i36p9ok7bv9lygcih.jpeg'
      image.upload_path.wont_be_nil
      image.status.must_equal Image::COMPLETE
      image.fixerable_final?.must_equal true
    end

    it 'rescues from unknown image types' do
      perform_porter_callback do
        [{
          'Task' => 'Copy',
          'Mode' => 'AWS/S3',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/if3i36p9ok7bv9lygcih.jpeg',
          'Time' => '2020-03-18T13:27:42.115Z',
          'Timestamp' => 1584538062.115
        },
         {
           'Task' => 'Inspect',
           'Inspection' => {
             'Size' => 71484,
             'Audio' => {},
             'Image' => {
               'Width' => 450,
               'Height' => 450,
               'Format' => 'jpeg'
             },
             'Extension' => 'jpg',
             'MIME' => 'foobar'
           }
         }]
      end
      image.content_type.must_equal 'foobar'
    end

    it 'sets download errors' do
      perform_porter_callback do
        []
      end
      image.status.must_equal ImageCallbackWorker::NOTFOUND
      image.fixerable_final?.must_equal false
    end

    it 'sets validation errors' do
      perform_porter_callback do
        [{
          'Task' => 'Copy',
          'Mode' => 'AWS/S3',
          'BucketName' => 'prx-porter-sandbox',
          'ObjectKey' => 'public/user_images/20926/if3i36p9ok7bv9lygcih.jpeg',
          'Time' => '2020-03-18T13:27:42.115Z',
          'Timestamp' => 1584538062.115
        }]
      end
      image.status.must_equal ImageCallbackWorker::INVALID
      image.fixerable_final?.must_equal false
    end

    it 'sets resize errors' do
      perform_porter_callback do
        [
          {
            'Task' => 'Copy',
            'Mode' => 'AWS/S3',
            'BucketName' => 'prx-porter-sandbox',
            'ObjectKey' => 'public/user_images/20926/if3i36p9ok7bv9lygcih.jpeg',
            'Time' => '2020-03-18T13:27:42.115Z',
            'Timestamp' => 1584538062.115
          },
          {
            'Task' => 'Inspect',
            'Inspection' => {
              'Size' => 71484,
              'Audio' => {},
              'Image' => {
                'Width' => 450,
                'Height' => 450,
                'Format' => 'jpeg'
              },
              'Extension' => 'jpg',
              'MIME' => 'image/jpeg'
            }
          }
        ]
      end

      image.status.must_equal ImageCallbackWorker::FAILED
      image.fixerable_final?.must_equal false
    end

    it 'announces story updates for story-image' do
      perform_porter_callback
      last_message.wont_be_nil
      last_message['subject'].must_equal :story
      last_message['action'].must_equal :update
      JSON.parse(last_message['body'])['id'].must_equal image.story.id
    end

    it 'announces series updates for series-image' do
      perform_porter_callback(series_image)
      last_message.wont_be_nil
      last_message['subject'].must_equal :series
      last_message['action'].must_equal :update
      JSON.parse(last_message['body'])['id'].must_equal series_image.series.id
    end
  end
end

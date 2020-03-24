require 'test_helper'

describe Api::SeriesImagesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:series_image) { create(:series_image, series: series, purpose: nil) }
  let(:token) { StubToken.new(series.account.id, ['member'], user.id) }

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
    @request.env['CONTENT_TYPE'] = 'application/json'
    clear_messages
  end

  it 'should show' do
    series_image
    get(:show, api_request_opts(series_id: series_image.series_id, id: series_image.id))
    assert_response :success
  end

  it 'should update' do
    image_hash = { credit: 'blah credit' }
    put(:update, image_hash.to_json, api_request_opts(series_id: series.id, id: series_image.id))
    assert_response :success
    SeriesImage.find(series_image.id).credit.must_equal('blah credit')
  end

  it 'triggers image copy on update' do
    image_opt = { credit: 'second blah credit' }
    mock_image = Minitest::Mock.new series_image

    mock_image.expect :copy_upload!, true

    @controller.stub :authorize, true do
      @controller.stub :update_resource, mock_image do
        put(:update, image_opt.to_json, api_request_opts(series_id: series.id, id: series_image.id))
      end
    end

    mock_image.verify
  end

  it 'triggers image copy on create' do

    image_hash = {
      upload: 'http://thisisatest.com/guid1/image.gif',
      set_series_uri: api_series_url(series)
    }

    series_image = SeriesImage.where(series_id: series.id).build
    mock_image = Minitest::Mock.new(series_image)

    mock_image.expect :copy_upload!, true

    @controller.stub :authorize, true do
      @controller.stub :create_resource, mock_image do
        post(:create, image_hash.to_json, api_request_opts(series_id: series.id))
      end
    end

    mock_image.verify
  end

  it 'should announce image updates on both image and series' do
    image_hash = { credit: 'other blah credit' }
    put(:update, image_hash.to_json, api_request_opts(series_id: series.id, id: series_image.id))
    assert_response :success

    published_messages.length.must_equal 2
    img_message = published_messages.find { |msg| msg['subject'] == 'image' }
    series_message = published_messages.find { |msg| msg['subject'] == 'series' }

    img_message.wont_be_nil
    JSON.parse(img_message['body'])['id'].must_equal series_image.id

    series_message.wont_be_nil
    JSON.parse(series_message['body'])['id'].must_equal series.id
  end

  it 'should add an image' do
    original = series.default_image

    image_hash = {
      upload: 'http://thisisatest.com/guid1/image.gif',
      set_series_uri: api_series_url(series)
    }

    post(:create, image_hash.to_json, api_request_opts(series_id: series.id))
    assert_response :success
    last_message['subject'].to_s.must_equal 'image'
    last_message['action'].to_s.must_equal 'create'
    new_image = JSON.parse @response.body

    original.id.wont_equal new_image['id']
    series.images.last.id.must_equal new_image['id']
  end

  it 'deletes the image, touches the series' do
    series_update = series.updated_at
    delete :destroy, api_request_opts(series_id: series.id, id: series_image.id)
    assert_response :success
    -> { SeriesImage.find(series_image.id) }.must_raise(ActiveRecord::RecordNotFound)
    series_update.wont_equal series.reload.updated_at
  end

  it 'triggers image remove! on destroy' do
    mock_image = Minitest::Mock.new(series_image)

    mock_image.expect :remove!, true

    @controller.stub :authorize, true do
      @controller.stub :destroy_resource, mock_image do
        delete :destroy, api_request_opts(series_id: series.id, id: series_image.id)
      end
    end

    mock_image.verify
  end
end

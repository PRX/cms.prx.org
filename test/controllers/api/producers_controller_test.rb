require 'test_helper'

describe Api::ProducersController do

  let(:producer) { FactoryGirl.create(:producer) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: producer.id } )
    assert_response :success
  end

  it 'should list' do
    producer.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end

require 'test_helper'

describe Api::MusicalWorksController do

  let(:musical_work) { FactoryGirl.create(:musical_work) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: musical_work.id } )
    assert_response :success
  end

  it 'should list' do
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

end

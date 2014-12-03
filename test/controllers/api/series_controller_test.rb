require 'test_helper'

describe Api::SeriesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: series.id } )
    assert_response :success
  end

  it 'should list' do
    series.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end

require 'test_helper'

describe Api::AudioVersionTemplatesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:template) { create(:audio_version_template, series: series) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: template.id } )
    assert_response :success
  end

  it 'should list' do
    template.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it 'should list by series' do
    template.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json', series_id: series.id } )
    assert_response :success
  end
end

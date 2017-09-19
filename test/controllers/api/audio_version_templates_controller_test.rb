require 'test_helper'

describe Api::AudioVersionTemplatesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:template) { create(:audio_version_template, series: series) }
  let(:template2) { create(:audio_version_template, series: series) }
  let(:distribution) { create(:podcast_distribution, distributable: series) }
  let(:distribution_template) do
    create(:distribution_template,
           distribution: distribution,
           audio_version_template: template2)
  end

  it 'should show' do
    get(:show, api_request_opts(id: template.id))
    assert_response :success
  end

  it 'should list' do
    template.id.wont_be_nil
    get(:index, api_request_opts)
    assert_response :success
  end

  it 'should list by series' do
    template.id.wont_be_nil
    distribution_template.id.wont_be_nil
    get(:index, api_request_opts(series_id: series.id))
    assert_response :success
  end

  it 'should list by distribution' do
    distribution_template.id.wont_be_nil
    get(:index, api_request_opts(distribution_id: distribution.id))
    body = JSON.parse(response.body)
    ids = body['_embedded']['prx:items'].map { |item| item['id'] }
    ids.must_equal [template2.id]
    assert_response :success
  end

  it 'should list by distribution' do
    distribution_template.id.wont_be_nil
    get(:index, api_request_opts(distribution_id: 'anything'))
    body = JSON.parse(response.body)
    ids = body['_embedded']['prx:items'].map { |item| item['id'] }
    ids.must_equal []
    assert_response :success
  end
end

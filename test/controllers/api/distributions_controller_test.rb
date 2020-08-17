require 'test_helper'

describe Api::DistributionsController do

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:series) { create(:series, account: account) }
  let(:audio_version_template) { create(:audio_version_template, series: series) }
  let(:distribution) do
    create(:distribution, distributable: series).tap do |dist|
      dist.audio_version_templates << audio_version_template
    end
  end
  let(:token) { StubToken.new(account.id, ['cms:read-private cms:series'], user.id) }
  let(:bad_token) { StubToken.new(account.id, ['member'], user.id) }

  it 'should show' do
    get :show, api_request_opts(series_id: distribution.owner.id, id: distribution.id)
    assert_response :success
  end

  describe '#create' do

    before(:each) do
      class << @controller; attr_accessor :prx_auth_token; end
      @controller.prx_auth_token = token
    end

    it 'can create a podcast distribution for a series' do
      template_uri = "/api/v1/audio_version_templates/#{audio_version_template.id}"
      podcast_uri = 'http://feeder.prx.org/api/v1/podcast/12345'
      pd_hash = {
        kind: 'podcast',
        guid: 'SET TEMPLATE',
        set_audio_version_template_uri: template_uri
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      def @controller.after_create_resource(res)
        res.update_attributes!(url: 'http://feeder.prx.org/api/v1/podcast/12345')
      end
      post :create, pd_hash.to_json, api_request_opts(series_id: series.id)
      assert_response :success
      resource = JSON.parse(response.body)
      resource['_links']['prx:podcast']['href'].must_equal podcast_uri
      resource['_links']['prx:audio-version-template']['href'].must_equal template_uri
    end

    it 'can create a podcast distribution for a series with multiple templates' do
      template_uri = "/api/v1/audio_version_templates/#{audio_version_template.id}"
      podcast_uri = 'http://feeder.prx.org/api/v1/podcast/12345'
      pd_hash = {
        kind: 'podcast',
        guid: 'SET TEMPLATE',
        set_audio_version_template_uris: [template_uri]
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
      def @controller.after_create_resource(res)
        res.update_attributes!(url: 'http://feeder.prx.org/api/v1/podcast/12345')
      end
      post :create, pd_hash.to_json, api_request_opts(series_id: series.id)
      assert_response :success
      resource = JSON.parse(response.body)
      resource['_links']['prx:podcast']['href'].must_equal podcast_uri
      resource['_links']['prx:audio-version-templates']['count'].must_equal 1
    end

    describe 'with a token lacking appropriate permissions' do

      before(:each) do
        class << @controller; attr_accessor :prx_auth_token; end
        @controller.prx_auth_token = bad_token
      end

      it 'cannot create a podcast distribution' do
        template_uri = "/api/v1/audio_version_templates/#{audio_version_template.id}"
        podcast_uri = 'http://feeder.prx.org/api/v1/podcast/12345'
        pd_hash = {
          kind: 'podcast',
          guid: 'SET TEMPLATE',
          set_audio_version_template_uri: template_uri
        }
        @request.env['CONTENT_TYPE'] = 'application/json'
        def @controller.after_create_resource(res)
          res.update_attributes!(url: podcast_uri)
        end
        post :create, pd_hash.to_json, api_request_opts(series_id: series.id)
        assert_response :unauthorized
      end

    end
  end
end

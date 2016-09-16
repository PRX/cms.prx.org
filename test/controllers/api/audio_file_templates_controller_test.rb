require 'test_helper'

describe Api::AudioFileTemplatesController do
  let(:version_template) { create(:audio_version_template) }
  let(:template) { create(:audio_file_template, audio_version_template: version_template) }

  it 'should show' do
    get(:show, api_request_opts(audio_version_template_id: version_template.id, id: template.id))
    assert_response :success
  end

  it 'should list by audio version template' do
    template.id.wont_be_nil
    get(:index, api_request_opts(audio_version_template_id: version_template.id))
    assert_response :success
  end
end

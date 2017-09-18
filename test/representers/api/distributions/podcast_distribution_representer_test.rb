require 'test_helper'

describe Api::Distributions::PodcastDistributionRepresenter do

  let(:series) { create(:series) }
  let(:template) { create(:audio_version_template, series: series) }
  let(:distribution) { create(:podcast_distribution, audio_version_template: template) }
  let(:distribution_templates) do
    DistributionTemplate.create(distribution: distribution, audio_version_template: template)
  end
  let(:representer) do
    distribution_templates
    Api::Distributions::PodcastDistributionRepresenter.new(distribution)
  end
  let(:json) { JSON.parse(representer.to_json) }

  before do
    stub_request(:get, 'http://feeder.docker/api/v1').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('feeder_root'))

    stub_request(:post, 'http://feeder.docker/api/v1/podcasts').
      with(headers: { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' }).
      to_return(status: 200, body: json_file('podcast'))
  end

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal distribution.id
    json['properties']['explicit'].must_equal 'clean'
  end

  it 'should have a link to an audio version template' do
    template_path = "/api/v1/audio_version_templates/#{template.id}"
    json['_links']['prx:audio-version-template']['href'].must_equal template_path
  end
end

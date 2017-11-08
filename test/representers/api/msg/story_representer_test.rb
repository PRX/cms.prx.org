require 'test_helper'

describe Api::Msg::StoryRepresenter do

  let(:story) { create(:story, audio_versions_count: 1) }
  let(:representer) { Api::Msg::StoryRepresenter.new(story) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(json, name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the public self url' do
    get_link_href(json, 'self').must_match /api\/v1\/stories\/\d+/
  end

  it 'has audio with storage urls' do
    af = json['_embedded']['prx:audio']['_embedded']['prx:items'].first
    get_link_href(af, 'prx:storage').must_match /s3:\/\//
  end

  it 'has an id on a deleted resource' do
    story.destroy
    json = JSON.parse(Api::Msg::StoryRepresenter.new(story).to_json)
    json['_links']['self']['href'].must_match /api\/v1\/stories\/\d+/
  end

  it 'does embed images' do
    json['_embedded']['prx:images'].wont_be_nil
  end
end

require 'test_helper'

describe Api::Auth::StoryRepresenter do

  let(:pub_story) { create(:story) }
  let(:pub_representer) { Api::Auth::StoryRepresenter.new(pub_story) }
  let(:pub_json) { JSON.parse(pub_representer.to_json) }

  let(:draft_story) { create(:unpublished_story) }
  let(:draft_representer) { Api::Auth::StoryRepresenter.new(draft_story) }
  let(:draft_json) { JSON.parse(draft_representer.to_json) }

  def get_link_href(json, name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href(pub_json, 'self').must_match /authorization\/stories\/\d+/
  end

  it 'keeps the unpublish link in the authorization namespace' do
    get_link_href(pub_json, 'prx:unpublish').must_match /authorization\/stories\/\d+/
  end

  it 'keeps the publish link in the authorization namespace' do
    get_link_href(draft_json, 'prx:publish').must_match /authorization\/stories\/\d+/
  end
end

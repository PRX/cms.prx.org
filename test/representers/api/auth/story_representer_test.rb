require 'test_helper'

describe Api::Auth::StoryRepresenter do

  let(:story) { create(:story) }
  let(:representer) { Api::Auth::StoryRepresenter.new(story) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href('self').must_match /authorization\/stories\/\d+/
  end

  it 'keeps the publish and unpublish links in the authorization namespace' do
    get_link_href('prx:unpublish').must_match /authorization\/stories\/\d+/
    story.unpublish!
    get_link_href('prx:publish').must_match /authorization\/stories\/\d+/
  end

end

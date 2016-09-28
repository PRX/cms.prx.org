require 'test_helper'

describe Api::Auth::AccountRepresenter do

  let(:account) { create(:account, stories_count: 2) }
  let(:representer) { Api::Auth::AccountRepresenter.new(account) }
  let(:json) { JSON.parse(representer.to_json) }

  before do
    account.stories.last.update(published_at: nil)
  end

  def get_link(rel, key = 'href')
    json['_links'][rel] ? json['_links'][rel][key] : nil
  end

  def get_embed(rel, key)
    json['_embedded'][rel] ? json['_embedded'][rel][key] : nil
  end

  it 'keeps the self url in the authorization namespace' do
    get_link('self').must_match /authorization\/accounts/
  end

  it 'links to authorized stories' do
    get_link('prx:stories').must_match /authorization\/accounts\/\d+\/stories/
    get_link('prx:stories', 'count').must_equal 2
  end

  it 'embeds all authorized stories' do
    account.public_stories.count.must_equal 1
    account.stories.count.must_equal 2
    get_embed('prx:stories', 'total').must_equal 2
  end
end

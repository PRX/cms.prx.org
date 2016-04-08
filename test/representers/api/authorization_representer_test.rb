require 'test_helper'

describe Api::AuthorizationRepresenter do

  let(:user) { create(:user) }
  let(:account) { user.default_account }
  let(:representer) { Api::AuthorizationRepresenter.new(user) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link(rel, key = 'href')
    json['_links'][rel] ? json['_links'][rel][key] : nil
  end

  def get_embed(rel, key)
    json['_embedded'][rel] ? json['_embedded'][rel][key] : nil
  end

  it 'links to the default account' do
    get_link('prx:default-account').must_match /authorization\/accounts\/#{account.id}/
  end

  it 'links to all accounts' do
    get_link('prx:accounts').must_match /authorization\/accounts/
  end

  it 'embeds the default account with the auth url' do
    get_embed('prx:default-account', 'id').must_equal account.id
    links = get_embed('prx:default-account', '_links')
    links['self']['href'].must_match /authorization\/accounts\/#{account.id}/
  end

  it 'embeds all accounts with their auth urls' do
    get_embed('prx:accounts', 'count').must_equal 1
    items = get_embed('prx:accounts', '_embedded')['prx:items']
    items.count.must_equal 1
    items[0]['_links']['self']['href'].must_match /authorization\/accounts\/#{account.id}/
  end
end

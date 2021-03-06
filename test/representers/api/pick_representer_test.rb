describe Api::PickRepresenter do

  let(:pick)        { create(:pick, is_root_resource: true) }
  let(:representer) { Api::PickRepresenter.new(pick) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal pick.id
  end

  it 'has an editorsTitle property' do
    json['editorsTitle'].must_equal pick.editors_title
  end

  it 'has a comment property' do
    json['comment'].must_equal pick.comment
  end

  it 'links the account' do
    json['_links']['prx:account']['href'].must_match /#{pick.account.id}/
  end

  it 'links the story' do
    json['_links']['prx:story']['href'].must_match /#{pick.story.id}/
  end

  it 'embeds the account' do
    json['_embedded']['prx:account']['id'].must_equal pick.account.id
  end

  it 'embeds the story' do
    json['_embedded']['prx:story']['id'].must_equal pick.story.id
  end

end

describe Api::PickListRepresenter do

  let(:pick_list)   { create(:pick_list) }
  let(:representer) { Api::PickListRepresenter.new(pick_list) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal pick_list.id
  end

  it 'has title property' do
    json['title'].must_equal pick_list.title
  end

  it 'has description property' do
    json['description'].must_equal pick_list.description
  end

  it 'has links for the picks' do
    json['_links']['prx:picks']['href'].must_match /#{pick_list.id}\/picks/
  end

  it 'embeds the picks' do
    json['_embedded']['prx:picks'].wont_be_nil
  end

end

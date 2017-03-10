require 'test_helper'

describe Api::Msg::SeriesRepresenter do
  let(:series)      { FactoryGirl.create(:series) }
  let(:representer) { Api::Msg::SeriesRepresenter.new(series) }
  let(:json)        { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the public self url' do
    get_link_href('self').must_match /api\/v1\/series\/\d+/
  end

  it 'does not embed stories' do
    json['_embedded']['prx:stories'].must_be_nil
  end
end

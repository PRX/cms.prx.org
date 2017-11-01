require 'test_helper'

describe Api::Auth::SeriesRepresenter do
  let(:series)      { FactoryGirl.create(:series) }
  let(:representer) { Api::Auth::SeriesRepresenter.new(series) }
  let(:json)        { JSON.parse(representer.to_json(zoom: 'prx:stories')) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  def get_embedded_href(name)
    json['_embedded'][name]['_links']['self']['href']
  end

  it 'yields authorization links for embedded stories' do
    get_link_href('prx:stories').must_include('authorization')
    get_embedded_href('prx:stories').must_include('authorization')
  end
end

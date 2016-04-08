require 'test_helper'

describe Api::Auth::AccountMinRepresenter do

  let(:account) { create(:account) }
  let(:representer) { Api::Auth::AccountMinRepresenter.new(account) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href('self').must_match /authorization\/accounts/
  end

  it 'links to authorized stories' do
    get_link_href('prx:stories').must_match /authorization\/accounts\/\d+\/stories/
  end

end

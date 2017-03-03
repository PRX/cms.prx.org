require 'test_helper'

describe Api::Auth::PodcastImportRepresenter do

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:podcast_url) { 'http://feeds.prx.org/transistor_stem' }
  let(:series) { create(:series, account: account) }
  let(:importer) { PodcastImport.create(user: user, account: account, url: podcast_url, series: series) }
  let(:representer) { Api::Auth::PodcastImportRepresenter.new(importer) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href('self').must_match /authorization\/accounts\/\d+\/podcast_imports\/\d+/
  end

  it 'has basic attributes and links' do
    importer.status
    json['status'].must_equal 'created'
    json['url'].must_equal podcast_url
    get_link_href('prx:series').must_match /series/
    get_link_href('prx:account').must_match /account/
  end
end

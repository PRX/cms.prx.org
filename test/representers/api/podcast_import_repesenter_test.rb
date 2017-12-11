# encoding: utf-8

require 'test_helper'

describe Api::PodcastImportRepresenter do
  let(:podcast_import) { FactoryGirl.create(:podcast_import) }
  let(:representer) { Api::PodcastImportRepresenter.new(podcast_import) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal podcast_import.id
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href('self').must_match /authorization\/podcast_imports\/\d+/
  end

  it 'has basic attributes and links' do
    json['status'].must_equal 'created'
    json['url'].must_equal 'http://feeds.prx.org/transistor_stem'
    get_link_href('prx:series').must_match /series/
  end
end

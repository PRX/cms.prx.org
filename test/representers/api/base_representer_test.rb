# encoding: utf-8

require 'test_helper'

describe Api::BaseRepresenter do

  let(:test_object) { TestObject.new("test", true) }
  let(:representer) { Api::BaseRepresenter.new(test_object) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  # it 'use api representer to create json' do
  #   json['version'].must_equal '1.0'
  #   json.keys.sort.must_equal ['_links', 'version']
  # end

  # it 'return root doc with links for an api version' do
  #   json['_links']['self']['href'].must_equal '/api/1.0'
  #   json['_links']['prx:story'].size.must_equal 1
  #   json['_links']['prx:stories'].size.must_equal 1
  #   json['_links']['prx:series'].size.must_equal 2
  # end

end

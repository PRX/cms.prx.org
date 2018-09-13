# encoding: utf-8

require 'test_helper'

describe Api::BaseRepresenter do
  let(:t_object) { TestObject.new('test', true) }
  let(:representer) { Api::BaseRepresenter.new(t_object) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it '#index_url_params' do
    representer.index_url_params.wont_be_nil
    representer.index_url_params.must_equal '{?page,per,zoom,filters,sorts}'
  end

  it '#search_url_params' do
    representer.search_url_params.wont_be_nil
    representer.search_url_params.must_equal '{?page,per,zoom,filters,sorts,q}'
  end
end

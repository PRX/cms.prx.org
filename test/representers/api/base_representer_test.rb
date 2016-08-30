# encoding: utf-8

require 'test_helper'

describe Api::BaseRepresenter do

  let(:t_object) { TestObject.new("test", true) }
  let(:representer) { Api::BaseRepresenter.new(t_object) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end
end

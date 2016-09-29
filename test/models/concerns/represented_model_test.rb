# encoding: utf-8

require 'test_helper'

class TestRepresentedModel
  include RepresentedModel
end

describe RepresentedModel do
  let(:represented) { TestRepresentedModel.new.tap { |m| m.is_root_resource = true } }

  it 'add naming' do
    represented.model_name.wont_be_nil
  end

  it 'sets root resource' do
    represented.must_be :is_root_resource

    represented.is_root_resource = false
    represented.wont_be :is_root_resource
  end

  it 'returns if curies should be added' do
    represented.must_be :show_curies
  end
end

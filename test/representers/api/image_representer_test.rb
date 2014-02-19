# encoding: utf-8

require 'test_helper'
require 'story_image'

describe Api::ImageRepresenter do

  let(:image)       { FactoryGirl.create(:story_image) }
  let(:representer) { Api::ImageRepresenter.new(image) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal image.id
  end

end

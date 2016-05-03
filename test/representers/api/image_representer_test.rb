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

  it 'gets the medium representation of an image' do
    image.stub :public_url, ->(opts){ opts[:version] } do
      json['_links']['enclosure']['href'].must_equal 'medium'
    end
  end

  it 'has an image profile' do
    json['_links']['profile']['href'].must_equal 'http://meta.prx.org/model/image/story'
  end
end

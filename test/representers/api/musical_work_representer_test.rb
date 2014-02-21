# encoding: utf-8

require 'test_helper'
SimpleCov.command_name 'test:representers'

require 'musical_work' if !defined?(AudioFile)

describe Api::MusicalWorkRepresenter do

  let(:musical_work)  { FactoryGirl.create(:musical_work) }
  let(:representer)   { Api::MusicalWorkRepresenter.new(musical_work) }
  let(:json)          { JSON.parse(representer.to_json) }
  
  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal musical_work.id
  end

end

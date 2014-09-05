# encoding: utf-8

require 'test_helper'

describe Api::StoryRepresenter do

  let(:story)       { build_stubbed(:story_with_audio, audio_versions_count: 1, id: 212) }
  let(:representer) { Api::StoryRepresenter.new(story) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal story.id
  end

  it 'does not serialize a length property' do
    json.keys.wont_include('length')
  end

  it 'serializes the length of the story as duration' do
    story.stub(:duration, 212) do
      json['duration'].must_equal 212
    end
  end

  it 'serializes the default image' do
    image = create(:story_image)
    story.stub(:default_image, image) do
      json['_links']['prx:image']['href'].must_match /#{image.id}/
    end
  end

  it 'will not serialize default image when not available' do
    story.stub(:default_image, nil) do
      json['_links'].keys.wont_include 'prx:image'
    end
  end

  it 'has a profile for the default image' do
    image = create(:story_image)
    representer.stub(:prx_model_uri, 'string') do
      story.stub(:default_image, image) do
        json['_links']['prx:image']['profile'].must_equal 'string'
      end
    end
  end

  it 'includes a content advisory' do
    sigil = 'sigil'
    story.stub(:content_advisory, sigil) do
      json['contentAdvisory'].must_equal sigil
    end
  end

  it 'includes timing and cues' do
    sigil = 'sigil'
    story.stub(:timing_and_cues, sigil) do
      json['timingAndCues'].must_equal sigil
    end
  end

  it 'includes topics and tones as tags' do
    topics = create_list(:topic, 2, story: story)
    tones = create_list(:tone, 2, story: story)
    story.stub(:tags, story.tags) do
      json['tags'].must_equal story.tags
    end
  end

  describe Api::Min::StoryRepresenter do
    let(:representer) { Api::Min::StoryRepresenter.new(story) }

    it 'serializes the length of the story as duration' do
      story.stub(:duration, 212) do
        json['duration'].must_equal 212
      end
    end

  end

end

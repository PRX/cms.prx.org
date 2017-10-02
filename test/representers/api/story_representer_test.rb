# encoding: utf-8

require 'test_helper'

describe Api::StoryRepresenter do

  let(:story) { create(:story, audio_versions_count: 1) }
  let(:representer) { Api::StoryRepresenter.new(story) }
  let(:json) { JSON.parse(representer.to_json) }

  describe 'deserialize' do

    it 'can deserialize from json' do
      json = representer.to_json
      d_representer = Api::StoryRepresenter.new(Story.new)
      d_story = d_representer.from_json(json)
      d_story.wont_be_nil
    end

    it 'can set the account' do
      story_hash = { title: 'title', set_account_uri: 'api/v1/accounts/8' }
      d_representer = Api::StoryRepresenter.new(Story.new)
      d_story = d_representer.from_json(story_hash.to_json)
      d_story.title.must_equal 'title'
      d_story.account_id.must_equal 8
    end
  end

  describe 'status flags' do
    let(:invalid_audio_versions) { create_list(:audio_version_with_template, 5) }
    let(:valid_audio_versions) { create_list(:audio_version, 5) }

    it 'shows complete status if story has all valid and complete audio' do
      story.audio_versions.wont_be(:empty?)
      story.update(title: 'Title!')
      json.keys.must_include('status')
      json['status'].must_equal 'complete'
    end

    it 'shows invalid, plus errors, if story is invalid' do
      story.audio_versions = invalid_audio_versions
      story.update(title: 'Title!')
      representer = Api::StoryRepresenter.new(story)
      json = JSON.parse(representer.to_json)

      json.keys.must_include('statusMessage')
      json['status'].must_equal 'invalid'
      json['statusMessage'].must_include 'Invalid audio version:'
    end
  end

  describe 'serialize' do

    it 'can serialize an unsaved story' do
      json = Api::StoryRepresenter.new(story).to_json
      json.wont_be_nil
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

    it 'has a story profile' do
      json['_links']['profile']['href'].must_equal 'http://meta.prx.org/model/story'
    end

    it 'includes a content advisory' do
      sigil = 'sigil'
      story.stub(:content_advisory, sigil) do
        json['contentAdvisory'].must_equal sigil
      end
    end

    it 'includes a transcript' do
      sigil = 'sigil'
      story.stub(:transcript, sigil) do
        json['transcript'].must_equal sigil
      end
    end

    it 'includes timing and cues' do
      sigil = 'sigil'
      story.stub(:timing_and_cues, sigil) do
        json['timingAndCues'].must_equal sigil
      end
    end

    it 'includes topics, tones and formats as tags' do
      tags = ['Art', 'Women', 'Fresh Air-ish']
      story.stub(:tags, tags) do
        json['tags'].must_equal tags
      end
    end

    it 'includes the created date' do
      date = DateTime.parse('1999-12-31 23:59:59')
      story.stub(:created_at, date) do
        DateTime.parse(json['createdAt']).must_equal(date)
      end
    end

    it 'includes the updated date' do
      date = DateTime.parse('1970-01-01 00:01:00')
      story.stub(:updated_at, date) do
        DateTime.parse(json['updatedAt']).must_equal(date)
      end
    end
  end

  describe 'audio versions' do
    it 'includes the audio versions' do
      json['_embedded']['prx:audio-versions'].wont_be_nil
    end
  end

  describe 'story and series info' do
    let(:schedule) { create(:schedule) }
    let(:series) { schedule.series }
    let(:story) do
      create(:story,
             series: series,
             clean_title: 'soapy clean',
             episode_identifier: '#2',
             season_identifier: 's1')
    end
    let(:representer) { Api::StoryRepresenter.new(story) }
    let(:json) { JSON.parse(representer.to_json) }

    it 'links to the series' do
      json['_links']['prx:series']['href'].must_match /#{series.id}/
    end

    it 'includes clean title' do
      json['cleanTitle'].must_equal 'soapy clean'
    end

    it 'includes episode identifier' do
      json['episodeIdentifier'].must_equal '#2'
    end

    it 'includes season number' do
      json['seasonIdentifier'].must_equal 's1'
    end

    it 'includes episode date' do
      json['episodeDate'].must_equal story.episode_date
    end

    it 'has none of this when story is not in a series' do
      story2 = create(:story)
      json = JSON.parse(Api::StoryRepresenter.new(story2).to_json)
      json['_links'].keys.wont_include('prx:series')
      json.keys.wont_include('episode_number')
      json.keys.wont_include('episode_date')
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

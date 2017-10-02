require 'test_helper'
require 'feeder_importer'

describe FeederImporter do

  let(:account_id) { 8 }
  let(:user_id) { 8 }
  let(:podcast_id) { 40 }
  let(:importer) { FeederImporter.new(account_id, user_id, podcast_id) }

  it 'makes a new importer' do
    importer.wont_be_nil
  end

  it 'retrieves the feeder podcast' do
    remote_podcast = importer.retrieve_podcast
    remote_podcast.wont_be_nil
    remote_podcast.title.must_equal 'Transistor'
  end

  it 'creates a series' do
    importer.retrieve_podcast
    series = importer.create_series
    series.wont_be_nil
    series.title.must_equal 'Transistor'
    series.account_id.must_equal 8
    series.creator_id.must_equal 8
    series.short_description.must_match /^A podcast of scientific questions/
    series.description_html.must_match /^<p>Transistor is podcast of scientific curiosities/

    series.images.profile.wont_be_nil
    puts "series.images.profile.upload: #{series.images.profile.upload}"
    series.images.profile.upload.must_equal podcast.itunes_image['url']

    series.images.thumbnail.wont_be_nil
    series.images.thumbnail.upload.must_equal podcast.feed_image['url']

    series.audio_version_templates.size.must_equal 1
    series.audio_version_templates.first.audio_file_templates.size.must_equal 1

    series.distributions.size.must_equal 1
  end

  # it 'creates a story from an episode' do
  #   importer.podcast = podcast
  #   importer.create_series(podcast)
  #   importer.create_story(podcast, podcast.episodes.first)
  # end
end

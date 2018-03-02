require 'test_helper'
require 'feeder_importer'

describe FeederImporter do

  let(:account_id) { 8 }
  let(:user_id) { 8 }
  let(:podcast_id) { 40 }
  let(:importer) { FeederImporter.new(account_id, user_id, podcast_id, true) }

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
    podcast = importer.podcast
    series = importer.create_series
    series.wont_be_nil
    series.title.must_equal 'Transistor'
    series.account_id.must_equal 8
    series.creator_id.must_equal 8
    series.short_description.must_match /^A podcast of scientific questions/
    series.description_html.must_match /^<p>Transistor is podcast of scientific curiosities/

    series.images.profile.wont_be_nil
    series.images.profile.upload.must_match /prx-up.s3.amazonaws.com\/test\/.+\/transistor1400.jpg/
    orig_re = /pub\/.+\/0\/web\/series_image\/\d+\/original\/transistor1400.jpg/
    podcast.itunes_image['original_url'].must_match orig_re

    series.images.thumbnail.wont_be_nil
    series.images.thumbnail.upload.must_match /prx-up.s3.amazonaws.com\/test\/.+\/transistor300.png/
    orig_re = /pub\/.+\/0\/web\/series_image\/\d+\/original\/transistor300.png/
    podcast.feed_image['original_url'].must_match orig_re

    series.audio_version_templates.size.must_equal 2
    series.audio_version_templates.first.audio_file_templates.size.must_equal 1
    series.audio_version_templates.first.segment_count.must_equal 1
    series.audio_version_templates.first.must_equal importer.audio_template

    series.distributions.size.must_equal 1
  end

  it 'creates a story from an episode' do
    importer.retrieve_podcast
    podcast = importer.podcast
    podcast.wont_be_nil
    series = importer.create_series
    series.wont_be_nil
    episode = podcast.episodes.first
    episode.wont_be_nil

    # manually alter dates to test they are set correctly
    # since test fixture data lacks published_at value
    now = Time.now
    episode.published_at = now

    # tweek description so we verify we get content
    episode.description = 'this is the description'

    story = importer.create_story(episode)
    story.wont_be_nil

    story.app_version.must_equal PRX::APP_VERSION
    story.creator_id.must_equal user_id
    story.account_id.must_equal account_id

    story.title.must_equal episode.title
    story.short_description.must_equal episode.subtitle
    story.description_html[0..32].must_equal episode.content[0..32]
    story.description_html[0..32].wont_equal episode.description[0..32]
    story.tags.must_equal episode.categories
    story.published_at.must_equal now
    story.released_at.must_equal now

    version = story.audio_versions.first
    version.wont_be_nil
    version.audio_version_template.must_equal importer.audio_template
    version.explicit.must_equal episode.explicit
    version.audio_files.count.must_equal 1

    file = episode.media_resources.first.original_url.sub(/.+\//, '')
    audio = version.audio_files.first
    audio.upload.must_equal "https://prx-up.s3.amazonaws.com/test/#{episode.guid}/#{file}"
    original_url = episode.media_resources.first.original_url
    original_url.must_equal "s3://test.mediajoint.prx.org/public/audio_files/#{audio.id}/#{file}"

    story.images.count.must_equal 1
    image = story.images.first
    file = 'transistor1400x1400.jpg'
    image.upload.must_equal "https://prx-up.s3.amazonaws.com/test/#{episode.guid}/#{file}"
    episode_image = episode.episode_images.first
    episode_image.original_url.must_match /\/0\/web\/story_image\/#{image.id}\/original\/#{file}/

    story.distributions.count.must_equal 1
    distro = story.distributions.first
    distro.distribution.must_equal importer.distribution
    distro.guid.must_equal episode.item_guid
    distro.url.must_match /feeder.prx.org\/api\/v1\/episodes\/#{episode.guid}/

    episode.prx_uri.must_equal "/api/v1/stories/#{story.id}"
    episode.url.must_equal "https://beta.prx.org/stories/#{story.id}"
  end

  it 'updates the podcast to synch with the series' do
    importer.retrieve_podcast
    importer.create_series
    importer.podcast.prx_account_uri.must_be_nil
    importer.podcast.explicit = 'no'

    importer.update_podcast
    importer.podcast.prx_account_uri.must_equal "/api/v1/accounts/#{account_id}"
    importer.podcast.prx_uri.must_equal "/api/v1/series/#{importer.series.id}"
    importer.podcast.source_url.must_be_nil
    importer.podcast.explicit.must_equal 'clean'
  end

  it 'locks the podcast to prevent publishing mid-import' do
    importer.retrieve_podcast
    importer.lock_podcast!
    importer.podcast.must_be :locked?
  end

  it 'does a full import' do
    importer.import
    importer.series.id.wont_be_nil
    importer.stories.count.must_equal Episode.count
  end
end

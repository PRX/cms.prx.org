require 'test_helper'

describe AudioFile do

  let(:audio_file) { FactoryGirl.create(:audio_file) }

  let(:audio_file_uploaded) { FactoryGirl.create(:audio_file_uploaded) }

  it 'has a table defined' do
    AudioFile.table_name.must_equal 'audio_files'
  end

  it 'has an asset_url' do
    audio_file.asset_url.must_match "/public/audio_files/#{audio_file.id}/test.mp2"
  end

  it 'has an public_asset_filename' do
    audio_file.public_asset_filename.must_equal audio_file.filename
  end

  it 'can update the underlying file' do
    audio_file.update_file!('test2.mp3')
    audio_file.filename.must_equal 'test2.mp3'
  end

  it 'can have a url from the upload' do
    audio_file_uploaded.filename.must_equal 'test.mp3'
  end

  it 'can have an asset_url from an upload' do
    audio_file_uploaded.asset_url.must_equal audio_file_uploaded.upload
  end

  it 'can have a signed url from an upload' do
    audio_file_uploaded.upload = 's3://prx-development/another.mp3'
    asset_url = audio_file_uploaded.asset_url
    asset_url.must_match /another.mp3/
    asset_url.must_match /X-Amz-Expires/
    asset_url.must_match /X-Amz-Credential/
  end

  it 'can set expiration on asset_url from an upload' do
    audio_file_uploaded.upload = 's3://prx-development/another.mp3'
    one_day_url = audio_file_uploaded.asset_url(expiration: 3600)
    one_day_url.must_match /X-Amz-Expires=3600/
  end

  it 'can get a provider for a url scheme' do
    AudioFile.storage_providers['s3'].must_equal 'AWS'
  end

  it 'can get the storage provider for a uri' do
    AudioFile.storage_provider_for_uri('google://g.com/p/f.mp3').must_equal 'Google'
  end

  it 'can returned a signed url for a file' do
    signed_url = audio_file_uploaded.signed_url('s3://prx-development/another.mp3', expiration: 3600)
    signed_url.must_match /another.mp3/
    signed_url.must_match /X-Amz-Expires=3600/
  end

  it 'can determine an expiration time' do
    n = ::Fog::Time.now
    ::Fog::Time.stub(:now, n) do
      audio_file_uploaded.url_expires_at(expiration: 3600).must_equal (n + 3600)
    end
  end

  it 'updates story and version timestamps' do
    story = create(:story)
    version = create(:audio_version, story: story)
    audio_file.update_attribute(:audio_version_id, version.id)

    stamp = 2.minutes.ago
    story.update_attribute(:updated_at, stamp)
    version.update_attribute(:updated_at, stamp)

    audio_file.filename = 'something'
    audio_file.save!
    story.reload
    version.reload

    story.updated_at.must_be :>, stamp
    version.updated_at.must_be :>, stamp
  end
end

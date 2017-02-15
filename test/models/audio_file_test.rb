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
    audio_file_uploaded.public_asset_filename.must_equal 'test.mp3'
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

  it 'validates self based on template' do
    mock_version = MiniTest::Mock.new
    mock_version_template = MiniTest::Mock.new
    mock_templates_list = MiniTest::Mock.new
    mock_file_template = MiniTest::Mock.new

    mock_version.expect(:audio_version_template, mock_version_template)
    mock_version_template.expect(:audio_file_templates, mock_templates_list)
    mock_templates_list.expect(:find, mock_file_template)

    audio_file.stub(:audio_version, mock_version) do
      audio_file.update_attributes!(label: "Main Segment", position: 1)
    end
  end
end

require 'test_helper'

describe AudioFile do
  let(:audio_file_uploaded) { create(:audio_file_uploaded) }

  let(:audio_version) { create(:audio_version_with_template) }
  let(:file_templates) do
    create_list(:audio_file_template,
                3,
                audio_version_template: audio_version.audio_version_template)
  end
  let(:audio_file) { create(:audio_file, audio_version: audio_version) }

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
    audio_version.audio_version_template.wont_be_nil
    file_templates.find { |ft| ft.label == 'Main Segment' && ft.position == 1 }.tap do |ft|
      ft.length_minimum = 1
      ft.length_maximum = 10
    end
    audio_version.audio_version_template.audio_file_templates = file_templates

    audio_file.update_attributes(position: 1, label: 'Main Segment')
    audio_file.status_msg.must_include 'long, but must be'
    audio_file.wont_be(:compliant_with_template?)
    audio_file.status.must_equal 'invalid'

    audio_file.update_attributes(status: 'complete', length: 5)
    audio_file.status_msg.must_be_nil
    audio_file.status.wont_equal 'invalid'
    audio_file.must_be(:compliant_with_template?)
  end
end

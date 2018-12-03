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

  it 'handles out of order inserts' do
    av = create(:audio_version, audio_files_count: 0)
    av.audio_files.must_be :empty?
    af3 = av.audio_files.create!(position: 3, status: 'uploaded', upload: 'http://test.com/3.mp3')
    af3.position.must_equal 3
    af1 = av.audio_files.create!(position: 1, status: 'uploaded', upload: 'http://test.com/1.mp3')
    af2 = av.audio_files.create!(position: 2, status: 'uploaded', upload: 'http://test.com/2.mp3')
    af1.reload.position.must_equal 1
    af2.reload.position.must_equal 2
    af3.reload.position.must_equal 3
  end

  it 'does not reorder on delete' do
    av = create(:audio_version, audio_files_count: 0)
    av.audio_files.must_be :empty?
    af1 = av.audio_files.create!(position: 1, status: 'uploaded', upload: 'http://test.com/1.mp3')
    af2 = av.audio_files.create!(position: 2, status: 'uploaded', upload: 'http://test.com/2.mp3')
    af3 = av.audio_files.create!(position: 3, status: 'uploaded', upload: 'http://test.com/3.mp3')
    af2.destroy!
    af1.reload.position.must_equal 1
    af3.reload.position.must_equal 3
    av.save
    av.status.must_equal 'invalid'
    av.status_message.must_equal 'Audio file missing for position 2'
  end

  it 'has a table defined' do
    AudioFile.table_name.must_equal 'audio_files'
  end

  it 'has an asset_url' do
    audio_file.asset_url.must_match "/public/audio_files/#{audio_file.id}/test.mp2"
  end

  it 'has an public_asset_filename' do
    audio_file.public_asset_filename.must_equal audio_file.filename
  end

  it 'has an enclosure based on content type' do
    audio_file.content_type = 'foo/bar'
    audio_file.enclosure_url.must_match "/web/audio_file/#{audio_file.id}/original/test.mp2"
    audio_file.enclosure_content_type.must_match 'foo/bar'

    audio_file.content_type = 'audio/foo'
    audio_file.enclosure_url.must_match "/web/audio_file/#{audio_file.id}/broadcast/test.mp3"
    audio_file.enclosure_content_type.must_match 'audio/mpeg'
  end

  it 'can update the underlying file' do
    audio_file.update_file!('test2.mp3')
    audio_file.filename.must_equal 'test2.mp3'
  end

  it 'can have a url from the upload' do
    audio_file_uploaded.public_asset_filename.must_equal 'test.mp3'
  end

  it 'complete audio has a storage url' do
    s3_file = "s3://#{ENV['AWS_BUCKET']}/public/audio_files/#{audio_file.id}/test.mp2"
    audio_file.fixerable_final_storage_url.must_equal s3_file
    audio_file_uploaded.fixerable_final_storage_url.must_equal nil
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

    # simulate the touch chaing
    audio_file.run_callbacks(:commit)
    version.reload
    version.run_callbacks(:commit)
    story.reload

    story.updated_at.must_be :>, stamp
    version.updated_at.must_be :>, stamp
  end

  it 'validates self based on template' do
    audio_version.audio_version_template.wont_be_nil
    file_templates.find { |ft| ft.label == 'Main Segment' && ft.position == 1 }.tap do |ft|
      ft.length_minimum = 1
      ft.length_maximum = 10
    end
    audio_version.audio_version_template.update(content_type: AudioFile::VIDEO_CONTENT_TYPE)
    audio_version.audio_version_template.audio_file_templates = file_templates

    audio_file.update_attributes(position: 1, label: 'Main Segment')
    audio_file.status_message.must_include 'is not in video format'
    audio_file.wont_be(:compliant_with_template?)
    audio_file.status.must_equal 'invalid'

    audio_file.update_attributes(position: 1, label: 'Main Segment',
                                 content_type: 'video/x-mpeg', status: 'mp3s created')
    audio_file.status_message.must_include 'long but must be'
    audio_file.wont_be(:compliant_with_template?)
    audio_file.status.must_equal 'invalid'

    audio_file.update_attributes(status: 'mp3s created', length: 5)
    audio_file.status_message.must_be_nil
    audio_file.status.must_equal 'complete'
    audio_file.must_be(:compliant_with_template?)
  end

  it 'doesnt validate on template unless audio has processed successfully' do
    audio_file.update(status: 'failed')
    audio_file.update_attributes(position: 1, label: 'Main Segment')
    audio_file.status.must_equal 'failed'

    audio_file.update(status: 'not found')
    audio_file.update_attributes(position: 1, label: 'Main Segment2')
    audio_file.status.must_equal 'not found'

    audio_file.update(status: 'uploaded')
    audio_file.update_attributes(position: 1, label: 'Main Segment3')
    audio_file.status.must_equal 'uploaded'

    audio_file.update(status: 'transformed')
    audio_file.update_attributes(position: 1, label: 'Main Segment4')
    audio_file.status.must_equal 'complete'
  end
end

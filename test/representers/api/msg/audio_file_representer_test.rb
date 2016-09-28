require 'test_helper'

describe Api::Msg::AudioFileRepresenter do
  let(:representer) { Api::Msg::AudioFileRepresenter.new(audio) }
  let(:json)        { JSON.parse(representer.to_json) }

  describe 'with a completed upload' do
    let(:audio) { FactoryGirl.create(:audio_file) }

    it 'includes basic data' do
      json['id'].must_equal audio.id
      json['filename'].must_equal 'test.mp2'
      json['size'].must_be_nil
      json['status'].must_equal audio.status
    end

    it 'has no uploaded path' do
      json['uploadPath'].must_be_nil
    end

    it 'has a destination path' do
      json['destinationPath'].must_equal "public/audio_files/#{audio.id}"
    end
  end

  describe 'with an in-progress upload' do
    let(:audio) { FactoryGirl.create(:audio_file_uploaded) }

    it 'includes basic data' do
      json['id'].must_equal audio.id
      json['filename'].must_equal 'test.mp3'
      json['size'].must_be_nil
      json['caption'].must_be_nil
      json['credit'].must_be_nil
      json['status'].must_equal audio.status
    end

    it 'has the uploaded path' do
      json['uploadPath'].must_equal audio.upload_path
    end

    it 'has a destination path' do
      json['destinationPath'].must_equal "public/audio_files/#{audio.id}"
    end
  end
end

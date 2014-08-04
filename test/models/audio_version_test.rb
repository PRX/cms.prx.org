require 'test_helper'

describe AudioVersion do

  let(:audio_version) { create(:audio_version, audio_files_count: 1) }

  it 'has a table defined' do
    AudioVersion.table_name.must_equal 'audio_versions'
  end

  it 'has a length from audio files' do
    audio_version.audio_files.inject(0){|sum, af| sum += af.length}.must_equal 60
    audio_version.length(true).must_equal 60
  end

  it 'proxies #as_default_audio to audio_versions' do
    audio_version.as_default_audio.must_equal audio_version.audio_files
  end

  it 'proxies #default_audio_duration to length' do
    audio_version.default_audio_duration.must_equal audio_version.length
  end

  describe 'promo version' do
    let(:audio_version) { create(:audio_version, audio_files_count: 2, promos: true) }

    it 'returns the longest audio file for as_default_audio' do
      audio_version.audio_files.last.update_attribute(:length, 703)
      audio_version.as_default_audio.must_equal [audio_version.audio_files.last]
    end

    it 'returns the length of the longest promo for default_audio_duration' do
      audio_version.audio_files.last.update_attribute(:length, 571)
      audio_version.default_audio_duration.must_equal 571
    end
  end

  describe '#breaks' do
    BREAK_TYPES = {
      :news_hole_break? => 'News Hole',
      :floating_break? => 'Floating',
      :bottom_of_hour_break? => 'Bottom of the Hour',
      :twenty_forty_break? => '20 and 40 min'
    }

    BREAK_TYPES.each do |method, text|
      it "includes '#{text}' when ##{method}" do
        audio_version.stub(method, true) do
          audio_version.breaks.must_include text
        end
      end

      it "does not include '#{text}' when ##{method} is false" do
        audio_version.stub(method, false) do
          audio_version.breaks.wont_include text
        end
      end
    end

  end
end

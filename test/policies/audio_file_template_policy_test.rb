require 'test_helper'

describe AudioFileTemplatePolicy do
  let(:account) { create(:account) }
  let(:series) { create(:series, account: account) }
  let(:audio_version_template) { create(:audio_version_template, series: series) }
  let(:audio_file_template) { build_stubbed(:audio_file_template, audio_version_template: audio_version_template) }
  let(:token) { StubToken.new(series.account_id, ['member']) }
  let(:non_member_token) { StubToken.new(series.account_id + 1, ['no']) }
  let(:user) { build_stubbed(:user, id: token.user_id) }

  describe '#update? and #create?' do
    it 'returns true if user member of account that owns the template series' do
      AudioFileTemplatePolicy.new(token, audio_file_template).must_allow :update?
      AudioFileTemplatePolicy.new(token, audio_file_template).must_allow :create?
    end

    it 'returns false otherwise' do
      AudioFileTemplatePolicy.new(non_member_token, audio_file_template).wont_allow :update?
      AudioFileTemplatePolicy.new(non_member_token, audio_file_template).wont_allow :create?
    end
  end
end

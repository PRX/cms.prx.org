require 'test_helper'

describe SeriesAttributePolicy do
  describe '#update?' do
    let(:series) { build_stubbed(:series) }
    let(:template) { build_stubbed(:audio_version_template, series: series) }
    let(:member_token) { StubToken.new(series.account_id, ['member']) }
    let(:n_m_token) { StubToken.new(series.account_id + 1, ['no']) }

    it 'returns true if user is a member of series account' do
      SeriesAttributePolicy.new(member_token, template).must_allow :update?
    end

    it 'returns false if user is not present' do
      SeriesAttributePolicy.new(nil, template).wont_allow :update?
    end

    it 'returns false if user is not a member of series account' do
      SeriesAttributePolicy.new(n_m_token, template).wont_allow :update?
    end
  end
end

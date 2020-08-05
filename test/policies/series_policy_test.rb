require 'test_helper'

describe SeriesPolicy do
  describe '#update?' do
    let(:series) { build_stubbed(:series) }
    let(:member_token) { StubToken.new(series.account_id, ['cms:series']) }
    let(:n_m_token) { StubToken.new(series.account_id + 1, ['cms:series']) }
    let(:n_s_token) { StubToken.new(series.account_id, ['cms:account']) }

    it 'returns true if user is a member of series account' do
      SeriesPolicy.new(member_token, series).must_allow :update?
      SeriesPolicy.new(member_token, series).must_allow :create?
    end

    it 'returns false if user is not present' do
      SeriesPolicy.new(nil, series).wont_allow :update?
      SeriesPolicy.new(nil, series).wont_allow :create?
    end

    it 'returns false if user is not a member of series account' do
      SeriesPolicy.new(n_m_token, series).wont_allow :update?
      SeriesPolicy.new(n_m_token, series).wont_allow :create?
    end

    it 'returns false if token lacks series permission for account' do
      SeriesPolicy.new(n_s_token, series).wont_allow :update?
      SeriesPolicy.new(n_s_token, series).wont_allow :create?
    end
  end
end

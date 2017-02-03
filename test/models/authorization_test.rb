require 'test_helper'

describe Authorization do
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member'], 456) }
  let(:authorization) { Authorization.new(token) }
  let(:unauth_account) { create(:account) }

  it 'has a token' do
    authorization.token.wont_be_nil
  end

  it 'has a list of accounts authorized on token' do
    authorization.token_auth_accounts.must_include account
  end

  it 'has lists of stories and series belonging to accounts authorized on token' do
    authorization.token_auth_stories.must_equal account.stories
    authorization.token_auth_series.must_equal account.series
  end

  it 'checks against token to see if accounts are authorized' do
    authorization.authorized?(account).must_equal true
    authorization.authorized?(unauth_account).must_equal false
  end
end

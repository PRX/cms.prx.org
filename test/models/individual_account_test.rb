require 'test_helper'

describe IndividualAccount do

  let(:account) { FactoryGirl.create(:individual_account_with_owner) }

  it 'has a table defined' do
    IndividualAccount.table_name.must_equal 'accounts'
  end

  it 'has opener' do
    account.opener.wont_be_nil
  end

  it 'uses openers attributes' do
    %i[name image address].each do |attr|
      account.send(attr).must_equal account.opener.send(attr)
    end
    account.path.must_equal account.opener.login
  end

  it 'has first name as short name' do
    user = build_stubbed(:user, first_name: 'sigil')
    individual = build_stubbed(:individual_account, opener: user)
    individual.short_name.must_equal 'sigil'
  end

end

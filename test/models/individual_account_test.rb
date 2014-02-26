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
    [:name, :image, :address ].each do |attr|
      account.send(attr).must_equal account.opener.send(attr)
    end
    account.path.must_equal account.opener.login
  end

end




require 'test_helper'

describe Account do

  let(:account) { FactoryGirl.create(:account) }

  it 'has a table defined' do
    Account.table_name.must_equal 'accounts'
  end

  it 'has stories' do
    account.stories.count.must_be :>, 0
  end

end

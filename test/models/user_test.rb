require 'test_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }

  it 'has a table defined' do
    User.table_name.must_equal 'users'
  end

  it 'has a name' do
    user.name.must_equal 'Rick Astley'
  end

end

require 'test_helper'

describe Membership do

  let(:membership) { FactoryGirl.create(:membership) }

  it 'has a table defined' do
    Membership.table_name.must_equal 'memberships'
  end

end

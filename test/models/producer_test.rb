require 'test_helper'

describe Producer do

  let(:producer) { FactoryGirl.create(:producer) }
  let(:producer_with_user) { FactoryGirl.create(:producer_with_user) }

  it 'has a table defined' do
    Producer.table_name.must_equal 'producers'
  end

  it 'has a name from user or not' do
    producer_with_user.full_name.must_equal producer_with_user.user.name
    producer.full_name.must_equal producer.name
  end

end

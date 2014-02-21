require 'test_helper'

describe Address do

  let(:address) { FactoryGirl.create(:address) }

  it 'has a table defined' do
    Address.table_name.must_equal 'addresses'
  end

end

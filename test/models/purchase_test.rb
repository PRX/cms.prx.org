require 'test_helper'

describe Purchase do
  let(:purchase) { build_stubbed(:purchase) }

  it 'should have a table defined' do
    Purchase.table_name.must_equal 'purchases'
  end

  it 'should have a purchased item' do
    purchase.must_respond_to(:purchased)
  end

  it 'should have a purchaser' do
    purchase.must_respond_to(:purchaser)
  end

  it 'should have a purchaser account' do
    purchase.must_respond_to(:purchaser_account)
  end

  it 'should have a seller account' do
    purchase.must_respond_to(:seller_account)
  end

end

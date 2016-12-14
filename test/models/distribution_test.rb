require 'test_helper'

describe Distribution do

  let(:distribution) { create(:distribution) }

  it 'has a table defined' do
    Distribution.table_name.must_equal 'distributions'
  end

  it 'has an owner' do
    distribution.owner.wont_be_nil
  end

  it 'has an account' do
    distribution.account.wont_be_nil
    distribution.account.must_equal distribution.owner.account
  end

  it 'has properties' do
    distribution.properties.wont_be_nil
    distribution.properties["explicit"].must_equal "clean"
  end

  it 'can be created with valid attributes' do
    distribution.must_be :valid?
  end
end

require 'test_helper'

describe PurchasePolicy do
  let(:purchase) { create(:purchase) }
  let(:account) { purchase.purchaser_account }
  let(:admin_token) { StubToken.new(account.id, ['admin']) }
  let(:member_token) { StubToken.new(account.id, ['member']) }

  it 'allows admins to make purchases' do
    PurchasePolicy.new(admin_token, purchase).must_allow :create?
  end

  it 'prevents anyone from updating a purchase' do
    PurchasePolicy.new(admin_token, purchase).wont_allow :update?
  end

  it 'prevents anyone from destroying a purchase' do
    PurchasePolicy.new(admin_token, purchase).wont_allow :destroy?
  end
end

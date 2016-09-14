FactoryGirl.define do
  factory :user, aliases: [:opener, :creator] do

    address

    first_name 'Rick'
    last_name 'Astley'

    after(:build) do |user|
      user.default_account = user.individual_account
    end

    after(:create) do |user|
      account = create(:individual_account)
      create(:membership, user: user, account: account)
      user.update_attribute(:account_id, account.id)
    end

    factory :user_with_accounts do
      transient do
        group_accounts 1
      end

      after(:create) do |user, evaluator|
        create_list(:group_account, evaluator.group_accounts, user: user)
      end
    end
  end
end

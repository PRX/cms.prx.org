FactoryGirl.define do
  factory :user, aliases: [:opener, :creator] do

    individual_account
    address

    first_name 'Rick'
    last_name 'Astley'

    after(:build) do |user|
      user.default_account = user.individual_account
    end

    after(:create) do |user|
      create(:membership, user: user, account: user.individual_account)
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

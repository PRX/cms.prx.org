FactoryGirl.define do
  factory :user, aliases: [:opener, :creator] do
    transient do
      with_individual_account { true }
    end

    address

    first_name 'Rick'
    last_name 'Astley'
    sequence(:login)  { |n| "rickastley#{n}" }

    after(:create) do |user, evaluator|
      unless evaluator.with_individual_account
        user.individual_account.try(:destroy!)
      end
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

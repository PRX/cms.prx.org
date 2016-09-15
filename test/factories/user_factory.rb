FactoryGirl.define do
  factory :user, aliases: [:opener, :creator] do

    address

    first_name 'Rick'
    last_name 'Astley'

    after(:create) do |user, evaluator|
      user.individual_account = create(:individual_account)
      user.reload
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

FactoryGirl.define do
  factory :account do

    name 'name'

    opener

    address

    ignore do
      stories_count 2
    end

    after(:create) do |account, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, account: account)
    end

    factory :individual_account do
      type 'IndividualAccount'
    end

  end
end

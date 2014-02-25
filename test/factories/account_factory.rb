FactoryGirl.define do
  factory :account, class: GroupAccount do

    name 'name'

    address

    ignore do
      stories_count 2
    end

    after(:create) do |account, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, account: account)
    end

    factory :individual_account, class: IndividualAccount do

      opener

    end

  end
end

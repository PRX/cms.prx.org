FactoryGirl.define do
  factory :network do

    account

    name 'name'
    path 'network'
    description 'description'
    pricing_strategy 'all free'
    publishing_strategy 'members'
    notification_strategy 'members'

    transient do
      stories_count 2
    end

    after(:create) do |network, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, network: network)
    end
  end
end

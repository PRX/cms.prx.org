FactoryGirl.define do
  factory :series do
    account

    title 'title'
    subscription_approval_status 'PRX Approved'
    episode_start_at 1.year.ago
    episode_start_number 1

    transient do
      stories_count 2
    end

    after(:create) do |series, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, series: series)
    end
  end
end

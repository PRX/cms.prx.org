FactoryGirl.define do
  factory :series do

    account

    title 'title'

    ignore do
      stories_count 2
    end

    after(:create) do |series, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, series: series)
    end

  end
end

FactoryGirl.define do

  factory :topic do

    story
    sequence(:name) { Topic::TOPIC_NAMES.sample }

  end
end

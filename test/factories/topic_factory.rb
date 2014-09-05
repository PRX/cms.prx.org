FactoryGirl.define do

  factory :topic do

    story
    name Topic::TOPIC_NAMES.sample

  end
end

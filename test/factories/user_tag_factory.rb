FactoryGirl.define do
  factory :user_tag do
    sequence(:name) { |n| "tag#{n}" }
  end

  factory :tagging do
    user_tag
    taggable factory: :story
  end
end

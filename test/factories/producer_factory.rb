FactoryGirl.define do
  factory :producer do

    name 'name'

    factory :producer_with_user do
      user
    end

    factory :producer_with_user_and_story do
      user
      story
    end
  end
end

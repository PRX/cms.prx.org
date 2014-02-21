FactoryGirl.define do
  factory :producer do

    name 'name'

    factory :producer_with_user do
      user
    end

  end
end

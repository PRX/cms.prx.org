FactoryGirl.define do
  factory :user_image do

    user

    after(:create) { |si| si.update_file!('test.png') }

  end
end

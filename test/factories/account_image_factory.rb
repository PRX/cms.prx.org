FactoryGirl.define do
  factory :account_image do

    account

    after(:create) { |af| af.update_file!('test.png') }

  end
end

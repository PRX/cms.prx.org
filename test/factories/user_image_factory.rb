FactoryGirl.define do
  factory :user_image do

    user { create(:user, with_individual_account: false) }

    after(:create) { |si| si.update_file!('test.png') }

  end
end

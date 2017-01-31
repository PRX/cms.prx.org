FactoryGirl.define do
  factory :series_image do

    series
    purpose 'profile'

    after(:create) { |af| af.update_file!('test.png') }

  end
end

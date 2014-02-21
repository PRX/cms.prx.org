FactoryGirl.define do
  factory :series_image do

    series

    after(:create) { |af| af.update_file!('test.png') }

  end
end

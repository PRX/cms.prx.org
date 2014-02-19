FactoryGirl.define do
  factory :story_image do

    story

    after(:create) { |si| si.update_file!('test.png') }

  end
end

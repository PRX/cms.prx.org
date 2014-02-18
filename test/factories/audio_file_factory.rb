FactoryGirl.define do
  factory :audio_file do

    association :audio_version, factory: :audio_version

    length 60

    after(:create) { |af| af.update_file!('test.mp2') }

  end
end

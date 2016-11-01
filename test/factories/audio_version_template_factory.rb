FactoryGirl.define do
  factory :audio_version_template do
    series
    label 'test'
    length_minimum 10
    length_maximum 100
  end
end

FactoryGirl.define do
  factory :audio_version_template do
    series
    label 'Audio Version'
    length_minimum 10
    length_maximum 100
    factory :audio_version_template_with_file_templates do
      after(:create) do |avt|
        create_list(:audio_file_template, 3, audio_version_template: avt)
      end
    end
  end
end

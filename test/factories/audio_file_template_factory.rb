FactoryGirl.define do
  factory :audio_file_template do
    audio_version_template
    label 'segment'
    length_minimum 1
    length_maximum 10
  end
end

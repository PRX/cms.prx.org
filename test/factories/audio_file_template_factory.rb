FactoryGirl.define do
  factory :audio_file_template do
    audio_version_template
    length_minimum 1
    length_maximum 10
    label 'Main Segment'
    position 1
  end
end

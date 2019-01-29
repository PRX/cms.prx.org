FactoryGirl.define do
  factory :audio_version_template do

    transient do
      series { false }
    end

    label 'Audio Version'
    content_type 'audio/mpeg'
    length_minimum 10
    length_maximum 100

    after(:create) do |avt, evaluator|
      avt.series = create(:series, templates_count: 0) if evaluator.series
    end

    factory :audio_version_template_with_file_templates do
      after(:create) do |avt|
        create_list(:audio_file_template, 3, audio_version_template: avt)
      end
    end
  end
end

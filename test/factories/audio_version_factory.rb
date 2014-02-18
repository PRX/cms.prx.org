FactoryGirl.define do
  factory :audio_version do

    label 'Audio Version'
    timing_and_cues 'Timing and cues'
    promos false

    ignore do
      audio_files_count 1
    end

    after(:create) do |audio_version, evaluator|
      FactoryGirl.create_list(:audio_file, evaluator.audio_files_count, audio_version: audio_version)
    end

    factory :promos do
      promos true
    end

  end
end
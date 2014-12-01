FactoryGirl.define do
  factory :audio_version do

    label 'Audio Version'
    timing_and_cues 'Timing and cues'
    content_advisory 'Content Advisory'
    promos false

    ignore do
      audio_files_count 0
    end

    after(:create) do |audio_version, evaluator|
      c = evaluator.audio_files_count
      c = (rand(5) + 1) if (evaluator.audio_files_count == 0)
      FactoryGirl.create_list(:audio_file, c, audio_version: audio_version)
    end

    factory :promos do
      promos true
    end
  end
end

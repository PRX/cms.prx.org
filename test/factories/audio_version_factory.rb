FactoryGirl.define do
  factory :audio_version do

    label 'Audio Version'
    timing_and_cues 'Timing and cues'
    content_advisory 'Content Advisory'
    transcript 'Transcript of all the text in this audio'
    promos false
    status 'complete'

    transient do
      audio_files_count 1
    end

    after(:create) do |audio_version, evaluator|
      c = evaluator.audio_files_count
      c = (rand(5) + 1) if (evaluator.audio_files_count == 0)
      c = 0 if evaluator.audio_files_count < 0
      (1..c).each { |i| FactoryGirl.create(:audio_file, audio_version: audio_version, position: i) }
      audio_version.reload
    end

    factory :promos do
      promos true
    end

    factory :audio_version_with_template do
      audio_version_template
    end
  end
end

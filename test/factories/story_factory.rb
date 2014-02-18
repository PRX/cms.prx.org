FactoryGirl.define do
  factory :story do

    association :promos, factory: :promos

    title 'Story Title'
    length 120
    short_description 'Short description'
    description 'Long description'
    published_at 1.week.ago
    produced_on 2.weeks.ago
    related_website 'http://prx.org'
    broadcast_history 'Broadcast history'

    factory :story_with_audio do

      ignore do
        audio_versions_count 1
      end

      after(:create) do |story, evaluator|
        FactoryGirl.create_list(:audio_version, evaluator.audio_versions_count, story: story)
      end

    end

  end
end

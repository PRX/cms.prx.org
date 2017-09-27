FactoryGirl.define do
  factory :story do

    account

    promos

    title 'Story Title'
    length 120
    point_level 1
    short_description 'Short description'
    description 'Long description'
    episode_identifier '123'
    season_identifier '1'
    produced_on 2.weeks.ago
    related_website 'http://prx.org'
    broadcast_history 'Broadcast history'
    published_at 1.week.ago

    transient do
      audio_versions_count 1
      images_count 1
    end

    after(:create, :stub) do |story, evaluator|
      create_list(:audio_version, evaluator.audio_versions_count, story: story)
      create_list(:story_image, evaluator.images_count, story: story)
    end

    factory :story_with_license do
      license
    end

    factory :story_with_purchases do
      transient do
        purchases_count 2
      end

      after(:create, :stub) do |story, evaluator|
        create_list(:purchase, evaluator.purchases_count, purchased: story)
      end
    end

    factory :story_promos_only do
      published_at nil
      promos_only_at 1.week.ago

      after(:create, :stub) do |story, evaluator|
        create(:promos, story: story)
      end
    end

    factory :story_v3 do
      after(:create, :stub) do |story, _evaluator|
        story.update_attributes(app_version: 'v3', deleted_at: nil)
      end
    end

    factory :unpublished_story do
      after(:create, :stub) do |story, _evaluator|
        story.update_attributes(published_at: nil)
      end
    end

  end
end

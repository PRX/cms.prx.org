FactoryGirl.define do
  factory :series do
    account

    title 'title'
    subscription_approval_status 'PRX Approved'
    episode_start_at 1.year.ago
    episode_start_number 1

    transient do
      stories_count 2
      templates_count 1
      dist_count 1
      images_count 1
    end

    after(:create) do |series, evaluator|
      FactoryGirl.create_list(:story, evaluator.stories_count, series: series)
      FactoryGirl.create_list(:audio_version_template, evaluator.templates_count, series: series)
      FactoryGirl.create_list(:podcast_distribution, evaluator.dist_count, distributable: series)
      FactoryGirl.create_list(:series_image, evaluator.images_count, series: series)
    end

    factory :series_v3 do
      after(:create, :stub) do |series, _evaluator|
        series.update_attributes(app_version: 'v3')
      end
    end
  end
end

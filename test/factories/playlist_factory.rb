FactoryGirl.define do
  factory :playlist do

    account

    after(:create, :stub) do |playlist, evaluator|
      create_list(:playlist_section, 2, playlist: playlist)
    end

  end

  factory :portfolio do
    account
  end
end

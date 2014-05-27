FactoryGirl.define do
  factory :playlist do

    account

    path 'name'

    after(:create, :stub) do |playlist, evaluator|
      create_list(:playlist_section, 2, playlist: playlist)
    end

  end
end

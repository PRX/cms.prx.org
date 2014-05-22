FactoryGirl.define do
  factory :pick_list do

    account

    after(:create, :stub) do |picklist, evaluator|
      create_list(:playlist_section, 2, pick_list: picklist)
    end

  end
end

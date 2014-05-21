FactoryGirl.define do
  factory :pick_list do

    account

    after(:create) do |picklist, evaluator|
      FactoryGirl.create_list(:playlist_section, 2, pick_list: picklist)
    end

  end
end

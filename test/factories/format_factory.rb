FactoryGirl.define do
  factory :format do
    story

    sequence(:name) { Format::FORMAT_NAMES.sample }
  end
end

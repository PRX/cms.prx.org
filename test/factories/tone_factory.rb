FactoryGirl.define do
  factory :tone do
    story

    sequence(:name) { Tone::TONE_NAMES.sample }
  end
end

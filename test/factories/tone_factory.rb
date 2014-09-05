FactoryGirl.define do
  factory :tone do
    story

    name Tone::TONE_NAMES.sample
  end
end

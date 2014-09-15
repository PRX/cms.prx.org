FactoryGirl.define do
  factory :purchase do
    purchased factory: :story
    purchaser factory: :user
    purchaser_account { purchaser.default_account }
    seller_account factory: :account
  end
end

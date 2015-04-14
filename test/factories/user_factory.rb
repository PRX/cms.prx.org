FactoryGirl.define do
  factory :user, aliases: [:opener, :creator] do

    individual_account
    default_account
    address

    first_name 'Rick'
    last_name 'Astley'
  end
end

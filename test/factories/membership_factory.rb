FactoryGirl.define do
  factory :membership do

    user

    account

    approved true
    role 'admin'
    request 'please add me!'

  end
end

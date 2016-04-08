FactoryGirl.define do
  factory :account, class: 'GroupAccount' do

    name 'name'

    address

    transient do
      stories_count 2
      user false
    end

    status 'open'

    after(:create) do |account, evaluator|
      create_list(:story, evaluator.stories_count, account: account)
      create(:membership, account: account, user: evaluator.user) if evaluator.user
    end

    factory :group_account, class: 'GroupAccount' do
      name 'group'
    end

    factory :individual_account, class: 'IndividualAccount', aliases: [:default_account] do
      name 'individual'
    end

    factory :individual_account_with_owner, class: 'IndividualAccount' do
      name 'individual with opener'
      opener
    end

  end
end

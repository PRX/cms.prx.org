FactoryGirl.define do
  factory :license do

    website_usage 'only with permission'
    allow_edit 'only with permission'
    additional_terms 'green m and ms'

  end
end

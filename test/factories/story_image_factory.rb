FactoryGirl.define do
  factory :story_image do

    story

    height 1400
    width 1400
    status 'complete'

    after(:create) { |si| si.update_file!('test.png') unless si.status == 'uploaded' }

    factory :story_image_uploaded do
      status 'uploaded'
      upload 'http://image.test.com/path/test.jpg'
    end
  end
end

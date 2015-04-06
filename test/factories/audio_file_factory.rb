FactoryGirl.define do
  factory :audio_file do

    audio_version

    length 60

    status 'complete'

    after(:create) { |af| af.update_file!('test.mp2') unless af.status == 'uploaded' }

    factory :audio_file_uploaded do
      status 'uploaded'
      upload 'http://audio.test.com/path/test.mp3'
    end
  end
end

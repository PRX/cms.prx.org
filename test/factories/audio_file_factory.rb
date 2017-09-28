FactoryGirl.define do
  factory :audio_file do

    audio_version

    length 60
    content_type 'audio/mpeg'
    layer 2
    frequency 44.1
    bit_rate 128
    channel_mode 'Single Channel'

    status 'complete'

    after(:create) { |af| af.update_file!('test.mp2') unless af.status == 'uploaded' }

    factory :audio_file_uploaded do
      status 'uploaded'
      upload 'http://audio.test.com/path/test.mp3'
    end
  end
end

require 'test_helper'

require 'account_image'

def extract_filename(uri)
  URI.parse(uri).path.split('?')[0].split('/').last  
end

describe AudioFileUploader do

  include CarrierWave::Test::Matchers

  let(:account_image) { FactoryGirl.create(:account_image) }
  let(:uploader) { account_image.file }

  it 'creates uploader' do
    uploader.wont_be_nil
  end

  # it 'returns a full_filename' do
  #   uploader.full_filename('test.mp2').must_equal 'test.mp2'
  #   uploader.preview.full_filename('test.mp2').must_equal 'test_preview.mp3'
  #   uploader.full_original_filename.must_equal ''
  # end

  # it 'returns a url' do
  #   extract_filename(uploader.url).must_equal 'test.mp2'
  #   extract_filename(uploader.url(:preview)).must_equal 'test_preview.mp3'
  # end

  it 'has a whitelist' do
    uploader.extension_white_list.must_include 'gif'
  end

end

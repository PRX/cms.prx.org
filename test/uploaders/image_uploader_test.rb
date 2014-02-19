require 'test_helper'

require 'account_image'

describe AudioFileUploader do

  include CarrierWave::Test::Matchers

  let(:account_image) { FactoryGirl.create(:account_image) }
  let(:uploader) { account_image.file }

  it 'creates uploader' do
    uploader.wont_be_nil
  end

  it 'returns a full_filename' do
    uploader.full_filename('test.png').must_equal 'test.png'
    uploader.square.full_filename('test.png').must_equal 'test_square.png'
    uploader.full_original_filename.must_equal ''
  end

  it 'returns a url' do
    extract_filename(uploader.url).must_equal 'test.png'
    extract_filename(uploader.url(:square)).must_equal 'test_square.png'
  end

  it 'has a whitelist' do
    uploader.extension_white_list.must_include 'gif'
  end

end

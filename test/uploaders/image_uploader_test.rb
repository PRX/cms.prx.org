require 'test_helper'

require 'account_image'

def extract_filename(uri)
  URI.parse(uri).path.split('?')[0].split('/').last
end

describe ImageUploader do

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

  it 'signs head requests' do
    signed_get = uploader.url
    signed_get.must_equal(uploader.url)
    signed_get.wont_equal(uploader.authenticated_head_url)
  end

end

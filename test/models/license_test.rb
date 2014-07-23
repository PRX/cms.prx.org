require 'test_helper'

describe License do

  let(:license) { FactoryGirl.create(:license) }

  it 'has a table defined' do
    License.table_name.must_equal 'licenses'
  end

  it 'is editable when allow_edit is without permission' do
    license.allow_edit = 'without further permission'
    license.must_be :editable
  end

  it 'is not editable when allow_edit is with permission' do
    license.allow_edit = 'only with permission'
    license.wont_be :editable
  end

  it 'is not editable when allow_edit is never' do
    license.allow_edit = 'never'
    license.wont_be :editable
  end

  it 'is streamable when website_usage is downloadable' do
    license.website_usage = 'as a free MP3 download and stream'
    license.must_be :streamable
  end

  it 'is streamable when website_usage is stream only' do
    license.website_usage = 'as a stream only'
    license.must_be :streamable
  end

  it 'is not streamable when website_usage is with permission' do
    license.website_usage = 'only with permission'
    license.wont_be :streamable
  end
end

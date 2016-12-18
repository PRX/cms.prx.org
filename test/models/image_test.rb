require 'test_helper'

class TestImage < Image
  self.table_name = 'piece_images'
end

describe Image do
  let(:image) { TestImage.new }

  it 'is abstract and has no table' do
    Image.table_name.must_be_nil
  end

  it 'defines constants' do
    Image::COMPLETE.wont_be_nil
    Image::PURPOSES.wont_be :blank?
  end

  it 'knows if the state is final' do
    TestImage.new(status: Image::COMPLETE).must_be :fixerable_final?
    TestImage.new(status: Image::FAILED).wont_be :fixerable_final?
  end
end

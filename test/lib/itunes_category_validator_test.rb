require 'test_helper'
require 'itunes_category_validator'

describe ITunesCategoryValidator do
  it 'checks category' do
    ITunesCategoryValidator.must_be :category?, 'Arts'
    ITunesCategoryValidator.wont_be :category?, 'Origami'
  end

  it 'checks subcategory' do
    ITunesCategoryValidator.subcategory?('Design').must_equal 'Arts'
    ITunesCategoryValidator.subcategory?('Podcasting', 'Technology').must_equal nil
    ITunesCategoryValidator.subcategory?('Design', 'Comedy').must_equal nil
    ITunesCategoryValidator.subcategory?('Books', 'Arts').must_equal 'Arts'
    ITunesCategoryValidator.subcategory?('Paper').must_equal nil
  end
end

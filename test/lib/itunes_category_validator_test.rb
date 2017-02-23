require 'test_helper'
require 'itunes_category_validator'

describe ITunesCategoryValidator do
  it 'checks category' do
    ITunesCategoryValidator.must_be :category?, 'Arts'
    ITunesCategoryValidator.wont_be :category?, 'Origami'
  end

  it 'checks subcategory' do
    ITunesCategoryValidator.subcategory?('Design').must_equal true
    ITunesCategoryValidator.subcategory?('Podcasting', 'Technology').must_equal true
    ITunesCategoryValidator.subcategory?('Design', 'Comedy').must_equal false
    ITunesCategoryValidator.subcategory?('Paper').must_equal false
  end
end

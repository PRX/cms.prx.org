require 'test_helper'

describe Format do

  let(:format) { build(:format) }

  it 'has a table defined' do
    Format.table_name.must_equal 'formats'
  end

  it 'belongs to a story' do
    format.must_respond_to(:story)
  end

  it 'validates that name is included in list' do
    format.name = 'not a format'

    format.wont_be :valid?
  end

  it 'validates uniqueness of format to story' do
    story = create(:story)
    format1 = create(:format, story: story)
    format2 = build(:format, name: format1.name, story: story)

    format2.wont_be :valid?
  end

  describe '#to_tag' do

    it 'returns the format name if category is unchanged' do
      format.name = 'Special'

      format.to_tag.must_equal 'Special'
    end

    it 'returns Fundraising for fundraising-related formats' do
      format.name = 'Fundraising for Air: Music'

      format.to_tag.must_equal 'Fundraising'
    end

    it 'returns Debut for debut format' do
      format.name = 'Debut (not aired nationally)'

      format.to_tag.must_equal 'Debut'
    end

  end
end

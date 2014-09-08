require 'test_helper'

describe Format do

  let(:format) { build_stubbed(:format) }

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
end

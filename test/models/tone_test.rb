require 'test_helper'

describe Tone do

  let(:tone) { build_stubbed(:tone) }

  it 'has a table defined' do
    Tone.table_name.must_equal 'tones'
  end

  it 'belongs to a story' do
    tone.must_respond_to(:story)
  end

  it 'validates that name is included in list' do
    tone.name = 'not a tone'

    tone.valid?.must_equal false
  end

  it 'validates uniqueness of tone to story' do
    story = create(:story)
    tone1 = create(:tone, story: story)
    tone2 = build(:tone, name: tone1.name, story: story)

    tone2.valid?.must_equal false
  end
end

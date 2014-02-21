require 'test_helper'

describe MusicalWork do

  let(:musical_work) { FactoryGirl.create(:musical_work) }

  it 'has a table defined' do
    MusicalWork.table_name.must_equal 'musical_works'
  end

  it 'has valid attributes' do
    musical_work.album.wont_be_nil
  end

end

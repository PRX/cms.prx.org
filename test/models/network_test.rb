require 'test_helper'

describe Network do
  let(:network) { create(:network) }

  it 'has a table defined' do
    Network.table_name.must_equal 'networks'
  end

  it 'can create a valid network membership' do
    network.account.wont_be_nil
  end

  it 'returns a list of stories' do
    network.stories.count.must_equal 2
  end
end

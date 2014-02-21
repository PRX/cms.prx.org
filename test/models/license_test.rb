require 'test_helper'

describe License do

  let(:license) { FactoryGirl.create(:license) }

  it 'has a table defined' do
    License.table_name.must_equal 'licenses'
  end

end

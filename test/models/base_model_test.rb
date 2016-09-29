require 'test_helper'

# since it is abstract, need to think about how to test
describe BaseModel do
  it 'is abstract' do
    BaseModel.abstract_class.must_equal true
  end
end

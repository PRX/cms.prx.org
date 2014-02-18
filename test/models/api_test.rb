require 'test_helper'
SimpleCov.command_name 'test:units'

describe Api do

  let(:api) { Api.version('1.0') }

  it 'create an api with a version' do
    api.version.must_equal '1.0'
  end

end

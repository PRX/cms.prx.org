require 'test_helper'

describe SanitizedSearchQuery do

  it 'knows if it exists' do
    SanitizedSearchQuery.new(nil).present?.must_equal false
    SanitizedSearchQuery.new('').present?.must_equal false
    SanitizedSearchQuery.new('   ').present?.must_equal false
    SanitizedSearchQuery.new(' b ').present?.must_equal true
  end

  it 'strips spaces' do
    SanitizedSearchQuery.new('  ').to_s.must_equal nil
    SanitizedSearchQuery.new('  hello   world ').to_s.must_equal 'hello   world'
  end

  it 'escapes reserved characters' do
    SanitizedSearchQuery.new('hello:').to_s.must_equal 'hello\:'
    SanitizedSearchQuery.new('this & that !other').to_s.must_equal 'this \& that \!other'
  end

  it 'leaves wildcards alone' do
    SanitizedSearchQuery.new('hello*').to_s.must_equal 'hello*'
  end

  it 'escapes odd trailing quotes' do
    SanitizedSearchQuery.new('a "b" "c" okay').to_s.must_equal 'a "b" "c" okay'
    SanitizedSearchQuery.new('a "b" "c stuff here').to_s.must_equal 'a "b" \"c stuff here'
  end

  it 'removes trailing logical operators' do
    SanitizedSearchQuery.new('a AND b OR c NOT d').to_s.must_equal 'a AND b OR c NOT d'
    SanitizedSearchQuery.new('a AND b  NOT').to_s.must_equal 'a AND b'
    SanitizedSearchQuery.new('a AND b  NOT  AND').to_s.must_equal 'a AND b'
  end

  it 'removes consecutive logical operators' do
    SanitizedSearchQuery.new('a AND OR b').to_s.must_equal 'a AND b'
    SanitizedSearchQuery.new('a AND OR NOT b OR NOT c').to_s.must_equal 'a AND b OR c'
  end
end

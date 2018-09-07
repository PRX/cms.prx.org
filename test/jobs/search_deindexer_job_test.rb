require 'test_helper'

class MockDeindexerModel
  attr_accessor :id, :removed

  def initialize(args)
    @id = args[:id]
    @removed = false
  end

  def remove_from_index
    @removed = true
    self
  end
end

describe SearchDeindexerJob do

  let(:job) { SearchDeindexerJob.new }

  it 'removes from index' do
    job = SearchDeindexerJob.new('MockDeindexerModel', 1234)
    model = job.perform_now
    model.id.must_equal 1234
    model.removed.must_equal true
  end
end

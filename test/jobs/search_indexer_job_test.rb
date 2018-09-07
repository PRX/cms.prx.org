require 'test_helper'
require 'minitest/mock'

describe SearchIndexerJob do

  let(:job) { SearchIndexerJob.new }

  it 'reindexes a model' do
    model = MiniTest::Mock.new
    model.expect(:reindex, 'return-value')

    job = SearchIndexerJob.new(model)
    job.perform_now.must_equal 'return-value'
    model.verify
  end

  it 'handles not found exceptions' do
    model = MiniTest::Mock.new
    model.expect :reindex, 'return-value' do
      raise ActiveRecord::RecordNotFound.new
    end

    job = SearchIndexerJob.new(model)
    job.perform_now.must_equal true
    model.verify
  end
end

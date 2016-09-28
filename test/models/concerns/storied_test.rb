require 'test_helper'
require 'active_record'

describe Storied do

  class StoriedTestModel
    include ActiveModel::Model
    include Storied

    def stories
      Story.all
    end
  end

  let(:model) { StoriedTestModel.new }

  it 'can get relation to public stories' do
    StoriedTestModel.new.public_stories.wont_be_nil
    StoriedTestModel.new.public_stories.must_be_instance_of Story::ActiveRecord_Relation
  end
end

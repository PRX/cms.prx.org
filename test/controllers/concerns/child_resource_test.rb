require 'test_helper'

describe ChildResource do

  class SonController < ActionController::Base
    include ChildResource

    child_resource parent: 'mom', child: 'son'
  end

  let(:controller) { SonController.new }

  it 'is a child resource' do
    controller.must_be :is_child_resource?
  end
end

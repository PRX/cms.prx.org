require 'test_helper'

describe NestedImage do

  class NestedImageTestClass < Api::BaseRepresenter
    include NestedImage
  end

  it 'gets path to image of any type' do
    %w(account series story user).each do |parent|
      represented = create("#{parent}_image")
      representer = NestedImageTestClass.new(represented)
      path = representer.nested_image_path(represented)
      path.must_match /\/api\/v1\/#{parent.pluralize}\/#{represented.public_send(parent).id}\/image/
    end
  end
end

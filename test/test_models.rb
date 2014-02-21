TestObject = Struct.new(:title)

class Api::TestObjectRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :title

  def api_tests_path(represented)
    "/api/tests/#{represented.title}"
  end

  link :self do
    api_tests_path(represented)
  end
end

test_routes = Proc.new do
  namespace :api do
    resources :test_objects
  end
end
Rails.application.routes.eval_block(test_routes)

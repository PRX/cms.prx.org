TestObject = Struct.new(:title, :is_root_resource)
TestObject.send(:extend, ActiveModel::Naming)


TestParent = Struct.new(:id, :is_root_resource) do
  extend ActiveModel::Naming

  def to_param
    "#{id}"
  end

end

class Api::TestObjectRepresenter < Api::BaseRepresenter

  property :title

  def api_tests_path(rep)
    title = rep.respond_to?('[]') ? rep[:title] : rep.try(:title)
    "/api/tests/#{title}"
  end

end

def define_routes
  test_routes = Proc.new do
    namespace :api do
      resources :test_objects

      resources :test_parent do
        get 'test_objects', to: 'test_objects#index'
      end

    end
  end
  Rails.application.routes.eval_block(test_routes)
end

define_routes


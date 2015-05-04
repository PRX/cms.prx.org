TestObject = Struct.new(:title, :is_root_resource) do
  extend ActiveModel::Naming

  def persisted?; false; end
  def to_model; self; end
end


TestParent = Struct.new(:id, :is_root_resource) do
  extend ActiveModel::Naming

  def persisted?; false; end
  def to_model; self; end

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
  Rails.application.routes.draw do
    namespace :api do
      resources :test_objects

      resources :test_parent do
        get 'test_objects', to: 'test_objects#index'
      end

    end
  end
end


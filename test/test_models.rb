TestObject = Struct.new(:title)

class Api::TestRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :title

  def api_tests_path(represented)
    "/api/tests/#{represented.title}"
  end

  link :self do
    api_tests_path(represented)
  end
end

class Api::TestsRepresenter < Roar::Decorator
  include Api::PagedCollectionRepresenter

  def api_tests_path(represented)
    "/api/tests?page=#{represented[:page] || 1}"
  end

  collection :items, as: :tests, embedded: true, class: TestObject, decorator: Api::TestRepresenter
end


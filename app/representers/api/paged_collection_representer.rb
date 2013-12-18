module Api::PagedCollectionRepresenter
  include Roar::Representer::JSON::HAL

  property :count
  property :total

  link :self do
    helper(params)
  end

  link :prev do
    helper(params.merge(page: represented.prev_page)) unless represented.first_page?
  end

  link :next do
    helper(params.merge(page: represented.next_page)) unless represented.last_page?
  end

  link :first do
    helper(params.merge(page: nil))
  end

  link :last do
    helper(params.merge(page: represented.total_pages))
  end

  def params
    represented.params
  end

  def helper(*args)
    self.send(url_helper, *args)
  end

  def url_helper
    @_url_helper ||= (represented.try(:url_helper) || url_helper_method_from_class_name)
  end

  def url_helper_method_from_class_name
    self.class.name.underscore.gsub(/_representer$/, '').gsub('/', '_') + '_path'
  end

end

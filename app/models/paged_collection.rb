class PagedCollection

  attr_accessor :items, :request

  def initialize(items, request)
    self.items = items
    self.request = request
  end

  def params
    request.params
  end

  def count
    items.count
  end

  def total
    items.total_count
  end

  def prev_page
    items.prev_page
  end

  def next_page
    items.next_page
  end

  def total_pages
    items.total_pages
  end

  def first_page?
    items.first_page?
  end

  def last_page?
    items.last_page?
  end

end

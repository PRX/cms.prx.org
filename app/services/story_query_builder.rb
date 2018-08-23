class StoryQueryBuilder < ESQueryBuilder

  MAX_SEARCH_RESULTS = Story::MAX_SEARCH_RESULTS

  def default_fields
    ['title', 'short_description', 'description']
  end

  def apply_authz?
    current_user
  end

  def apply_published_filter?
    apply_authz?
  end

  private

  def build_filters
    bools = []
    if apply_published_filter?
      bools.push published_filter
    end
    if apply_authz?
      bools.push authz_filter
    end
    bools
  end

  def published_filter
    searchdsl = self
    Filter.new do
      term published: true
    end
  end

  def authz_filter
    searchdsl = self
    Filter.new do
      term account_id: searchdsl.current_user.account_ids
    end
  end

  def default_sort_params
    [published_at: :desc, updated_at: :desc]
  end
end

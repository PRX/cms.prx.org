class StoryQueryBuilder < ESQueryBuilder

  def default_max_search_results
    Story::MAX_SEARCH_RESULTS
  end

  def default_fields
    ['title', 'short_description', 'description']
  end

  def default_sort_params
    [published_at: :desc, updated_at: :desc]
  end

  def apply_authz?
    current_user
  end

  def apply_published_filter?
    !apply_authz? # TODO what else should trigger this?
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
      range published_at: { lte: 'now' }
    end
  end

  def authz_filter
    searchdsl = self
    Filter.new do
      term account_id: searchdsl.current_user.account_ids
    end
  end
end

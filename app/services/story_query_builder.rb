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
    authorization.present?
  end

  def apply_published_filter?
    !apply_authz? && has_network_query?
  end

  def has_network_query?
    structured_query.present? && structured_query.value_for(:network_id)
  end

  def apply_public_filter?
    !apply_authz? && !has_network_query?
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
    if apply_public_filter?
      bools.push published_filter
      bools.push v4_or_deleted_at_null_filter
      bools.push network_visible_filter
      bools.push series_visible_filter
    end
    bools
  end

  def published_filter
    searchdsl = self
    Filter.new do
      range published_at: { lte: 'now', _name: :published }
    end
  end

  def authz_filter
    searchdsl = self
    Filter.new do
      terms account_id: searchdsl.authorization.token_auth_accounts.try(:ids), _name: :authz
    end
  end

  def v4_or_deleted_at_null_filter
    Filter.new do
      bool do
        should do
          bool do
            must_not do
              exists field: :deleted_at, _name: :deleted_at_null
            end
          end
        end
        should do
          term app_version: { value: 'v4', _name: :app_version_v4 }
        end
      end
    end
  end

  def network_visible_filter
    Filter.new do
      bool do
        must_not do
          exists field: :network_only_at, _name: :network_visible
        end
      end
    end
  end

  def series_visible_filter
    Filter.new do
      bool do
        should do
          bool do
            must_not do
              term 'series.subscription_approval_status' => { value: 'PRX Approved', _name: :prx_series_approved }
            end
          end
        end
        should do
          bool do
            must_not do
              exists field: 'series.subscriber_only_at', _name: :series_subscriber_only_at
            end
          end
        end
      end
    end
  end
end

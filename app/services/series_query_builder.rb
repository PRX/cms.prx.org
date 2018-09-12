class SeriesQueryBuilder < ESQueryBuilder

  def default_fields
    ['title', 'short_description', 'description']
  end

  def default_sort_params
    [updated_at: :desc]
  end

  def apply_authz?
    authorization.present?
  end

  private

  def build_filters
    bools = []
    if apply_authz?
      bools.push authz_filter
    end
    bools.push v4_or_deleted_at_null_filter
    bools
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
end

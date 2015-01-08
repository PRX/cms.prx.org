describe HalActions do
  class HalActionsTestController < ActionController::Base
    include HalActions
    include Pundit

    def params
      { action: 'update' }
    end

    def current_user
      FactoryGirl.create(:user)
    end
  end

  let (:controller) { HalActionsTestController.new }
  let (:account) { create(:account) }

  it 'has cache options' do
    HalActionsTestController.cache_options.must_equal({compress: true, expires_in: 1.hour, race_condition_ttl: 30})
  end

  it 'can adds paging to resources query' do
    arel = HalActionsTestController.new.with_paging(Account.where('id is not null'))
    arel.to_sql.must_match /LIMIT 10 OFFSET 0/
  end

  describe '#update' do
    it 'authorizes the resource' do
      controller.stub(:authorize, true) do
        assert_send([controller, :authorize, account])
      end
    end
  end
end

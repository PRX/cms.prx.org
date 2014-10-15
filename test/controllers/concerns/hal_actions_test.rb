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
  let(:account) { create(:account) }

  it 'has cache options' do
    HalActionsTestController.cache_options.must_equal({compress: true, expires_in: 1.hour, race_condition_ttl: 30})
  end

  describe '#update' do
    it 'raises a pundit error if user is not authorized' do
      controller.stub(:resource, account) do
        begin
          controller.update
        rescue Pundit::NotAuthorizedError
          assert true
        else
          assert false
        end
      end
    end

    it 'does not raise a pundit error if user is authorized' do
      mem = create(:membership, account: account, user: create(:user))

      controller.stub(:resource, account) do
        controller.stub(:current_user, mem.user) do
          begin
            controller.update
          rescue Pundit::NotAuthorizedError
            assert false
          rescue => e
            assert true
          end
        end
      end
    end
  end
end

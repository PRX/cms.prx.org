describe HalActions do

  class HalActionsTestController < ActionController::Base
    include HalActions
  end

  let (:controller) { HalActionsTestController.new }

  it 'has cache options' do
    HalActionsTestController.cache_options.must_equal({compress: true, expires_in: 1.hour, race_condition_ttl: 30})
  end

end
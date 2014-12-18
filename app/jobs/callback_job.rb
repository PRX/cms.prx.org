# encoding: utf-8

class CallbackJob < ActiveJob::Base

  queue_as :default

  def perform(params)
    params = params.with_indifferent_access
    ActiveRecord::Base.connection_pool.with_connection do
      model = params[:class].camelize.constantize.find(params[:id])
      model.send("#{params[:kind]}_callback", params) if model.respond_to?("#{params[:kind]}_callback")
    end
  end
end

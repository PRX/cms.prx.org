# encoding: utf-8

class CallbacksController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def update
    callback_info = params.slice(:class, :id, :kind, :job)
    CallbackJob.enqueue(callback_info)
    head 202
  end

end

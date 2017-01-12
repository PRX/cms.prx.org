# encoding: utf-8

require 'active_support/concern'

module ResourceCallbacks
  extend ActiveSupport::Concern

  def create
    create_resource.tap do |res|
      consume! res, create_options
      hal_authorize res
      res.save!
      after_create_resource(res)
      respond_with root_resource(res), create_options
    end
  end

  def update
    update_resource.tap do |res|
      consume! res, show_options
      hal_authorize res
      res.save!
      after_update_resource(res)
      respond_with root_resource(res), show_options
    end
  end

  def destroy
    destroy_resource.tap do |res|
      hal_authorize res
      res.destroy
      after_destroy_resource(res)
      head :no_content
    end
  end

  def after_create_resource(_resource = nil); end
  def after_update_resource(_resource = nil); end
  def after_destroy_resource(_resource = nil); end
end

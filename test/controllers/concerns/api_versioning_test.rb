# encoding: utf-8

describe ApiVersioning do

  class ApiVersioningTestController < ActionController::Base
    include ApiVersioning
  end

  let (:controller) { ApiVersioningTestController.new }

  it 'has cache options' do
    ApiVersioningTestController.api_versions(:v0)
    ApiVersioningTestController.understood_api_versions.must_equal ['v0']
  end
end

# encoding: utf-8

require 'test_helper'
require 'url_representer_helper' if !defined?(UriHelper)

describe UriHelper do

  let(:helper) { class TestUrlHelper; include UriHelper; end.new }
  let(:test_object) { TestObject.new("test") }
  let(:representer) { Api::TestObjectRepresenter.new(test_object) }

  it 'creates a uri for a model' do
    uri = "http://meta.prx.org/model/test_object"
    helper.prx_model_uri('test_object').must_equal uri
    helper.prx_model_uri(:test_object).must_equal uri
    helper.prx_model_uri(TestObject).must_equal uri
    helper.prx_model_uri(test_object).must_equal uri

    uri = "http://meta.prx.org/model/account/individual"
    helper.prx_model_uri(IndividualAccount).must_equal uri
    helper.prx_model_uri(IndividualAccount.new).must_equal uri

    uri = "http://meta.prx.org/model/image/account"
    helper.prx_model_uri(AccountImage).must_equal uri
    helper.prx_model_uri(AccountImage.new).must_equal uri
  end

  it 'uses path template' do
    representer.api_tests_path_template(title: '{title}').must_equal "/api/tests/{title}"
  end

end

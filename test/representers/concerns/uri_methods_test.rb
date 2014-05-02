# encoding: utf-8

require 'test_helper'
require 'test_models'

describe UriMethods do

  let(:helper) { class TestUriMethods; include UriMethods; end.new }
  let(:t_object) { TestObject.new("test", true) }
  let(:representer) { Api::TestObjectRepresenter.new(t_object) }

  it 'creates a uri for a model' do
    uri = "http://meta.prx.org/model/test-object"
    helper.prx_model_uri('test_object').must_equal uri
    helper.prx_model_uri(:test_object).must_equal uri
    helper.prx_model_uri(TestObject).must_equal uri
    helper.prx_model_uri(t_object).must_equal uri

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

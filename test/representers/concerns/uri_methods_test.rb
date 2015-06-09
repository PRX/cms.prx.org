# encoding: utf-8

require 'test_helper'
require 'test_models'

describe UriMethods do

  let(:helper) { class TestUriMethods; include Rails.application.routes.url_helpers; include UriMethods; end.new }
  let(:t_object) { TestObject.new("test", true) }
  let(:representer) { Api::TestObjectRepresenter.new(t_object) }


  it 'gets the path for url to represented' do
    representer.prx_model_web_path(t_object).must_equal 'test_objects/1'
  end

  it 'helps an object become the represented base class' do
    class FooParent; end
    class FooChild < FooParent
      def self.base_class; FooParent; end
      def becomes(klass); 'became'; end
    end
    representer.becomes_represented_class(FooChild.new).must_equal 'became'
  end

  it 'creates a url to prx web site' do
    representer.prx_web_url('rainbows', 1).must_equal 'https://www.prx.org/rainbows/1'
  end

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

  it 'returns the meta host' do
    representer.prx_meta_host.must_equal 'meta.prx.org'
  end

  it 'returns the web host' do
    representer.prx_web_host.must_equal 'www.prx.org'
  end

  it 'uses path template for method missing' do
    representer.api_tests_path_template(title: '{title}').must_equal "/api/tests/{title}"
  end

  # can't get this to work
  # describe 'test paths' do

  #   before { define_routes }

  #   after { Rails.application.reload_routes! }

  #   it 'gets a self url for a represented object' do
  #     representer.self_url(t_object).must_equal '/api/test_objects/1'
  #   end
  # end
end

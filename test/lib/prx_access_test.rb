require 'prx_access'

class PRXAccessTest
  include PRXAccess
end

describe PRXAccess do
  let(:prx_access) { PRXAccessTest.new }
  let(:podcast) { JSON.parse(json_file(:podcast)) }
  let(:resource) { PRXAccess::PRXHyperResource.new }

  it 'returns an api' do
    prx_access.api.wont_be_nil
  end

  it 'returns root uri' do
    prx_access.id_root.wont_be_nil
    prx_access.cms_root.wont_be_nil
    prx_access.crier_root.wont_be_nil
    prx_access.feeder_root.wont_be_nil
  end

  it 'create a resource from json' do
    res = prx_access.api_resource(podcast, prx_access.feeder_root)
    res.wont_be_nil
    res.attributes['title'] = '99% Invisible'
  end

  it 'underscores incoming hash keys' do
    input = { 'camelCase' => 1 }
    resource.incoming_body_filter(input)['camel_case'].must_equal 1
  end

  it 'underscores outgoing hash keys' do
    input = { 'under_score' => 1 }
    resource.outgoing_body_filter(input)['underScore'].must_equal 1
  end

  it 'serializes using the outgoing_body_filter' do
    stub_request(:post, "https://cms.prx.org/api/v1").
      with(body: '{"underScore":1}').
      to_return(status: 200, body: '{"foo":"bar"}', headers: {})

    prx_access.api.post('under_score' => 1 )
  end
end

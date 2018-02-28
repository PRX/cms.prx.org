require 'test_helper'

describe Website do
  let (:website) { build_stubbed(:website) }

  it 'automatically adds a schema to urls that lack them' do
    website.url = 'prx.org'
    website.url.must_equal 'http://prx.org'
  end

  it 'does not impact urls that have schemas' do
    website.url = 'http://prx.org'
    website.url.must_equal 'http://prx.org'
  end

  it 'has an owner' do
    website.owner.must_equal website.browsable
  end

  it 'uses an owned policy' do
    Website.policy_class.must_equal OwnedPolicy
  end

  describe '#as_link' do
    it 'sets :href to #url' do
      website.url = 'http://example.com'
      website.as_link[:href].must_equal 'http://example.com'
    end
  end
end

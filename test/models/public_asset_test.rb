require 'test_helper'
require 'public_asset'

class BasePublicAsset
  include PublicAsset
end

class TestPublicAsset
  include PublicAsset

  attr_accessor :name
  def initialize(n); @name = n; end
  def id; 1; end
  def public_asset_filename; name; end
  def token_secret; 'secret'; end
  def asset_url(options={})
    v = options[:version]
    v = nil if (v.blank? || v.to_s == 'original')
    "test_public_asset/#{[v, public_asset_filename].join('/')}"
  end

end

describe PublicAsset do

  let(:public_asset) { TestPublicAsset.new('test.mp3') }
  let(:bare_public_asset) { BasePublicAsset.new }

  it 'generates a token using defaults' do
    public_asset.public_url_token.must_equal "5033d06991dc5b69e38275253bfb3b24"
  end

  it 'generates a public url' do
    public_asset.public_url.must_equal "http://prx-backend.dev/pub/5033d06991dc5b69e38275253bfb3b24/0/web/test_public_asset/1/original/test.mp3"
  end
  
  it 'sets default options' do
    defaults = public_asset.set_asset_option_defaults
    defaults[:use].must_equal 'web'
    defaults[:class].must_equal 'test_public_asset'
    defaults[:id].must_equal 1
    defaults[:version].must_equal 'original'
    defaults[:name].must_equal 'test'
    defaults[:extension].must_equal 'mp3'
    defaults[:expires].must_equal 0
  end

  it 'needs to have asset_url implemented' do
    proc{ bare_public_asset.asset_url}.must_raise NotImplementedError
  end

  it 'needs to have public_asset_filename implemented' do
    proc{ bare_public_asset.public_asset_filename }.must_raise NotImplementedError
  end

  it 'tests if valid' do    
    public_asset.public_url_valid?({}).must_equal false
  end

end

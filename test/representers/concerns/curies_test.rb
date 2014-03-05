# encoding: utf-8

require 'test_helper'

describe Curies do

  it 'sets a default curie' do

    class Test1Representer < Roar::Decorator
      include Roar::Representer::JSON::HAL
      include Curies

      use_curie(:test)
    end

    Test1Representer.default_curie.must_equal :test
  end

  it 'defines curie links' do
    class Test2Representer < Roar::Decorator
      include Roar::Representer::JSON::HAL
      include Curies

      curies(:test) do
        [{ name: :test, href: "http://meta.test.com/relation/{rel}", templated: true }]
      end
    end

    Test2Representer.link_configs.size.must_equal 1
    Test2Representer.link_configs.first.first[:rel].must_equal :curies
  end

end

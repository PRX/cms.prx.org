# encoding: utf-8

require 'test_helper'

describe LinkSerialize do

  it 'sets a default curie' do

    class Foo
      def self.id_for_url(url); 1; end
    end

    class TestRepresenter < Roar::Decorator
      include Roar::Representer::JSON::HAL
      include LinkSerialize

      link rel: :foo, writeable: true do
        { href: '/foo' }
      end

    end

    TestRepresenter.representable_attrs['set_foo_uri'].wont_be_nil
    TestRepresenter.representable_attrs['set_foo_uri'][:readable].must_equal false
    TestRepresenter.representable_attrs['set_foo_uri'][:reader].wont_be_nil
  end

end

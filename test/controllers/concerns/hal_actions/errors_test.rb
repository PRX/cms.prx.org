require 'test_helper'

describe HalActions::Errors do
  describe HalActions::Errors::UnsupportedMediaType do
    let(:subject) { HalActions::Errors::UnsupportedMediaType.new('foo') }

    it 'has status 415' do
      subject.status.must_equal 415
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
    end
  end

  describe HalActions::Errors::NotFound do
    let(:subject) { HalActions::Errors::NotFound.new }

    it 'has status 404' do
      subject.status.must_equal 404
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
    end
  end
end

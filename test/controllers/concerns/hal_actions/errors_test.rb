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
end

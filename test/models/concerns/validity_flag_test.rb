# encoding: utf-8

require 'test_helper'

class TestValidityFlagModel
  include ValidityFlag
end

describe TestValidityFlagModel do
  let(:model) { TestValidityFlagModel.new }

  it 'has access to status constants' do
    model.class::VALID.wont_be_nil
    model.class::INVALID.wont_be_nil
    model.class::NOTFOUND.wont_be_nil
    model.class::UPLOADED.wont_be_nil
    model.class::FAILED.wont_be_nil
    model.class::COMPLETE.wont_be_nil
    model.class::VALIDATING.wont_be_nil
    model.class::TRANSFORMING.wont_be_nil
    model.class::TRANSFORM_FAILED.wont_be_nil
    model.class::SINGLE_CHANNEL.wont_be_nil
    model.class::DUAL_CHANNEL.wont_be_nil
    model.class::STEREO.wont_be_nil
    model.class::JOINT_STEREO.wont_be_nil
    model.class::PROFILE.wont_be_nil
    model.class::THUMBNAIL.wont_be_nil
    model.class::PURPOSES.wont_be_nil
  end
end

require 'test_helper'

describe Economy do

  it 'has constants' do
    Economy.default_royalty_per_point.wont_be_nil
    Economy.points_per_minute.wont_be_nil
    Economy.minimum_royalty_payment.wont_be_nil
    Economy.default_package_points.wont_be_nil
    Economy.default_package_expiration.wont_be_nil
    Economy.default_package_grace_period.wont_be_nil
    Economy.default_prx_percentage.wont_be_nil
    Economy.license_free_pieces_price.wont_be_nil
    Economy.default_piece_expiration.wont_be_nil
    Economy.minimum_piece_point_value.wont_be_nil
  end

  it 'calculates points' do
    Economy.points(1, 60).must_equal Economy.points_per_minute
  end
end

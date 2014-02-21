# encoding: utf-8

# collect together values that work for the PRX economy
# with the logic to come up with interesting info such as calculating the values for bonuses or something.
class Economy

  # default rate for points per minute - this can be changed
  POINTS_PER_MINUTE            = 5 unless defined?(POINTS_PER_MINUTE)

  # minimum royalty payment to be paid out in a quarter on a statement
  MINIMUM_ROYALTY_PAYMENT      = 5.00 unless defined?(MINIMUM_ROYALTY_PAYMENT)

  # used for calculating the floor for royalties
  DEFAULT_ROYALTY_PER_POINT    = 0.10 unless defined?(DEFAULT_ROYALTY_PER_POINT)

  # used for creating free station accounts
  DEFAULT_PACKAGE_POINTS       = 600 unless defined?(DEFAULT_PACKAGE_POINTS)
  DEFAULT_PACKAGE_EXPIRATION   = 1.year unless defined?(DEFAULT_PACKAGE_EXPIRATION)
  DEFAULT_PACKAGE_GRACE_PERIOD = 3.months unless defined?(DEFAULT_PACKAGE_GRACE_PERIOD)
  DEFAULT_PRX_PERCENTAGE       = 20 unless defined?(DEFAULT_PRX_PERCENTAGE)

  LICENSE_FREE_PIECES_PRICE    = BigDecimal.new("250.00") unless defined?(LICENSE_FREE_PIECES_PRICE)

  # how long a piece is licensed for when purchased
  DEFAULT_PIECE_EXPIRATION     = 1.year unless defined?(DEFAULT_PIECE_EXPIRATION)

  MINIMUM_PIECE_POINT_VALUE    = 1 unless defined?(MINIMUM_PIECE_POINT_VALUE)

  class << self

    # I may end up moving these to the db, so use methods not constants
    def points_per_minute
      POINTS_PER_MINUTE
    end

    def default_royalty_per_point
      DEFAULT_ROYALTY_PER_POINT
    end

    def minimum_royalty_payment
      MINIMUM_ROYALTY_PAYMENT
    end

    def default_package_points
      DEFAULT_PACKAGE_POINTS
    end

    def default_package_expiration
      DEFAULT_PACKAGE_EXPIRATION
    end

    def default_package_grace_period
      DEFAULT_PACKAGE_GRACE_PERIOD
    end

    def default_prx_percentage
      DEFAULT_PRX_PERCENTAGE
    end

    def license_free_pieces_price
      LICENSE_FREE_PIECES_PRICE
    end

    def default_piece_expiration
      DEFAULT_PIECE_EXPIRATION
    end

    def minimum_piece_point_value
      MINIMUM_PIECE_POINT_VALUE
    end

    def points(level, seconds)
      lvl = level || 0
      return 0 if (lvl == 0 || seconds == 0)
      rt = seconds || 0
      [(((rt <= 0) ? 0 : rt.to_f/60.00) * (Economy.points_per_minute * lvl)).round, Economy.minimum_piece_point_value].max
    end

    # def price(tsr, hours)
    #   tsr ||= 0
    #   base_fee = min_max(250, 3500, (BigDecimal.new("0.0005") * tsr).round(2, BigDecimal::ROUND_HALF_UP))
    #   hour_fee = min_max(10,  100,  (BigDecimal.new("0.00001") * tsr).round(2, BigDecimal::ROUND_HALF_UP))
    #   BigDecimal.new((base_fee + (hour_fee * hours)).to_s)
    # end

    # def new_point_package(args)
    #   type = args[:package_type] || PointPackage::STANDARD
    #   hours = BigDecimal.new(args[:hours].to_s)
    #   pp = PointPackage.new(args)

    #   pp.package_type = type
    #   pp.discount = 0
    #   pp.prx_percentage = 0
    #   pp.expires_on = Time.now.to_date + Economy.default_package_expiration
    #   pp.ends_on = pp.expires_on

    #   if(type == PointPackage::STANDARD)
    #     pp.ends_on = pp.expires_on + Economy.default_package_grace_period
    #     pp.points = 60 * Economy.points_per_minute * hours
    #     pp.list = Economy.price(pp.total_station_revenue, pp.hours)
    #     pp.witholding = [((BigDecimal.new("0.01") * (Economy.default_prx_percentage || 0)) * (pp.list || 0)), 0].max
    #   elsif(type == PointPackage::COMPLIMENTARY)
    #     pp.prx_cut = 0
    #     pp.points = 60 * Economy.points_per_minute * hours
    #     pp.list = 0
    #   elsif(type == PointPackage::LICENSE_FREE_PIECES)
    #     pp.prx_cut = Economy.license_free_pieces_price
    #     pp.points = 0
    #     pp.list = Economy.license_free_pieces_price
    #   elsif(type == PointPackage::TRIAL)
    #     pp.prx_cut = 0
    #     pp.points = Economy.default_package_points
    #     pp.list = 0
    #   end

    #   pp

    # end

    private

    # def min_max(min, max, val)
    #   [ max, [ min, val].max ].min
    # end

  end

end

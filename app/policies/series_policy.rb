class SeriesPolicy < AccountablePolicy
  def initialize(token, series)
    super(token, series, :series)
  end
end

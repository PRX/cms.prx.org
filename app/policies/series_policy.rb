class SeriesPolicy < AccountablePolicy
  def initialize(token, series)
    super(token, series, :series)
  end
  
  def destroy?
    false
  end
end

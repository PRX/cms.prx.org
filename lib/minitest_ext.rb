class Minitest::Mock
  def tap
    yield self
    self
  end
end

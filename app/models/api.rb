class Api

  def self.version(version)
    new(version)
  end

  attr_accessor :version

  def initialize(version)
    @version = version
  end

end

class OrientationSensor
  attr_reader :pitch, :roll

  def initialize
    @pitch = 0
    @roll = 0
  end

  def update
    # some sensor interface to update pitch and roll
  end
end
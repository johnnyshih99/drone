class Gyroscope
  attr_reader :x, :y, :z

  def initialize
    @x = 0
    @y = 0
    @z = 0
  end

  def update
    # some sensor interface to update x, y, z
  end
end
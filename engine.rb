class Engine
  attr_reader :status, :power
  STATUS = ["on", "off"].freeze

  def initialize
    @status = "off"
    @power = 0
  end

  def power=(pow)
    @power = pow if pow >= 0 && power <= 100
  end

  def status=(s)
    @status = s if STATUS.include?(s)
  end
end
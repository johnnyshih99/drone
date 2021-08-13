require_relative 'engine'
require_relative 'gyroscope'
require_relative 'orientation_sensor'

class Drone
  attr_reader :status
  #STATUS = ["off", "hovering", "moving"].freeze
  # these numbers are totally arbitrary
  DEFAULT_POWER = 50
  LAND_VECLOTY = -1
  OUTSIDE_FORCE_THRESHOLD = 5

  def initialize
    @status = "off"
    @engines = {}
    @gyro = Gyroscope.new
    @orientation = OrientationSensor.new
    @engine_failure = false
    @stabilizing = false
  end

  def add_engine(x, y)
    # this allows flexible configuration
    # a quad copter could be configured for example
    # add_engine(5,0); add_engine(-5,0)
    # add_engine(0,5); add_engine(0,-5)
    key = "#{x},#{y}"
    if @engines[key].nil?
      @engines[key] = Engine.new
    else
      STDOUT.puts "engine at #{key} already exists"
    end
  end

  # move_(direction) doesn't really make drone
  # move in the specified direction instantly but instead
  # add more force that pushes the drone into that direction
  # imagine using a remote control, we'd have to keep
  # giving direction inputs to control the drone
  ["forward", "left", "right", "back", "up", "down"].each do |dir|
    define_method("move_#{dir}") {
      # moving happens after take off only
      # so we check engines here
      # stop checking if engine failure is known
      check_engines if !@engine_failure
      old_x, old_y, old_z = @gyro.x, @gyro.y, @gyro.z 
      add_force(dir)
      @gyro.update
      x, y, z = @gyro.x, @gyro.y, @gyro.z

      # when there's an outside force that makes the
      # drone go in unnatural ways 
      # e.g. tap the drone with hand
      if (!@stabilizing && ((x-old_x).abs > OUTSIDE_FORCE_THRESHOLD ||
        (x-old_x).abs > OUTSIDE_FORCE_THRESHOLD ||
        (x-old_x).abs > OUTSIDE_FORCE_THRESHOLD))
        @stabilizing = true
        stabilize
      else
        @status = "moving"
      end
    }
  end

  def take_off
    @engines.each do |key, engine|
      engine.status = "on"
      engine.power = DEFAULT_POWER
    end

    # maybe a sleep or retry loop here to allow take off
    @gyro.update 
    
    if @gyro.z <= 0
      STDOUT.puts "take_off failed"
      STDOUT.puts "landing"
      land
    else
      @status = "moving"
    end
  end

  def stabilize
    while @gyro.x != 0 || @gyro.y != 0 || @gyro.z != 0
      if @gyro.x > 0
        move_left
      elsif @gyro.x < 0
        move_right
      end

      if @gyro.y > 0
        move_back
      elsif @gyro.y < 0
        move_forward
      end

      if @gyro.z > 0
        move_down
      elsif @gyro.z < 0
        move_up
      end
      @gyro.update
    end

    @status = "hovering"
    @stabilizing = false
  end

  def land
    # stabilize x y plane first
    while @gyro.x != 0 || @gyro.y != 0
      if @gyro.x > 0
        move_left
      elsif @gyro.x < 0
        move_right
      end

      if @gyro.y > 0
        move_back
      elsif @gyro.y < 0
        move_forward
      end

      @gyro.update
    end

    while @status != "off"
      if @gyro.z < LAND_VECLOTY
        # falling too quick
        # engine power ++
        move_up
      elsif @gyro.z > LAND_VECLOTY
        # wrong direction
        # engine power --
        move_down
      end

      all_engine_off = false
      if @gyro.z == 0
        all_engine_off = true
        @engines.each do |key, engine|
          all_engine_off = false if engine.power > 0
        end
      end

      if all_engine_off
        @status = "off"
        @engines.each do |key, engine|
          engine.status = "off"
        end
      end

      @gyro.update
    end
  end

  private

  def check_engines
    @engines.each do |key, engine|
      if engine.status == "off"
        @engine_failure = true
        STDOUT.puts "engine at #{key} failed"
        STDOUT.puts "landing"
        land
        break
      end
    end
  end

  def add_force(dir)
    # the key in @engines is of format x,y
    # so we can calculate their @gyro.x/y/z contribution
    # depending on their position

    # involvement with pitch and roll will happen here
    case dir
    when "forward"
      # find engines contributing to y
      # power_for_y++
      # power_for_neg_y--
    when "back"
      # find engines contributing to y
      # power_for_neg_y++
      # power_for_y--
    when "left"
      # find engines contributing to x
      # power_for_neg_x++
      # power_for_x--
    when "right"
      # find engines contributing to x
      # power_for_x++
      # power_for_neg_x--
    when "up"
      # find engines contributing to z
      # maybe pair of engines with [x, -x], [y, -y]
      # power_for_z++
    when "down"
      # find engines contributing to z
      # power_for_z--
    end
  end
end
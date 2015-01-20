class CallRequest
  attr_accessor :floor, :direction

  def initialize(floor, direction)
    @floor = floor
    @direction = direction
  end
end
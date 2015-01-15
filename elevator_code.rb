class Elevator
  attr_accessor :current_floor, :destination_requests, :direction, :status, :column

  def initialize(column, current_floor = 1, direction = 'up', status = 'open')
    @column = column
    @current_floor = current_floor
    @direction = direction
    @destination_requests = []
    @status = status
  end

  def deactivate
    self.status = 'closed'
  end

  def re_activate
    self.status = 'open'
  end 

  def travel(floor)
    self.current_floor = floor
  end  

  def request_destination(destination)
    self.destination_requests << destination
  end

  def complete_request 
    travel(nearest_destination)
    self.destination_requests.shift
  end

  def set_direction
    if nearest_destination > self.current_floor
      self.direction = 'up'
    else
      self.direction = 'down'
    end
  end

  def nearest_destination
    self.destination_requests.sort_by{ |floor| (floor - self.current_floor).abs }.first
  end

end
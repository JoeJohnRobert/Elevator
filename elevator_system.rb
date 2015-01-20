require 'pry'

class ControlPanel
  attr_accessor :elevators, :floors, :call_requests

  def initialize(floors, *elevators)
    @elevators = [*elevators]
    @floors = floors
    @call_requests = []
  end

  def deactivate_all
    self.elevators.each do |elevator|
      elevator.current_floor = 1
      elevator.status = 'closed'
    end
  end

  def activate_all
    self.elevators.each{|elevator| elevator.status = 'open'}
  end

  def deactivate_elevator(column_number)
    self.elevators.each{|elevator| elevator.deactivate if elevator.column == column_number}
  end

  def re_activate_elevator(column_number)
    self.elevators.each{|elevator| elevator.re_activate if elevator.column == column_number}
  end

  def call(floor, direction)
    self.call_requests << CallRequest.new(floor, direction)
  end

  def dispatch
    destination = self.call_requests.shift
    nearest_elevator(destination).travel(destination)
  end

  def nearest_elevator(destination)
    sorted = self.elevators.sort_by{ |elevator| (elevator.current_floor - destination.floor).abs }
    sorted.select! do |elevator| 
      elevator.set_direction
      if destination.direction == 'up' 
        elevator.direction == 'up' && elevator.status == 'open' && elevator.current_floor < destination.floor   
      elsif destination.direction == 'down' 
        elevator.direction == 'down' && elevator.status == 'open' && elevator.current_floor > destination.floor 
      end 
    end
    sorted.first
  end

end
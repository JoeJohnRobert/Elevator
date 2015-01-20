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
    if destination.direction == 'up'
      find_up(sorted, destination) 
    else 
      find_down(sorted, destination) 
    end 
  end

  def find_up(sorted_elevators, destination)
    sorted_elevators.select! do |elevator|
      elevator.set_direction  
      elevator.direction == 'up' && elevator.status == 'open' && elevator.current_floor < destination.floor
    end
    sorted_elevators.first
  end

  def find_down(sorted_elevators, destination)
    sorted_elevators.select! do |elevator|
      elevator.set_direction  
      elevator.direction == 'down' && elevator.status == 'open' && elevator.current_floor > destination.floor 
    end
    sorted_elevators.first
  end
end
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

  def call(floor)
    self.call_requests << floor
  end

  def dispatch
    destination = self.call_requests.shift
    nearest_elevator(destination).travel(destination)
  end

  def nearest_elevator(destination)
    sorted = self.elevators.sort_by{ |elevator| (elevator.current_floor - destination).abs }
    sorted.select! do |elevator| 
      elevator.set_direction
      if elevator.destination_requests.max >= destination && elevator.current_floor < destination   
        elevator.direction == 'up' && elevator.status == 'open'
      elsif elevator.destination_requests.min <= destination && elevator.current_floor > destination 
        elevator.direction == 'down' && elevator.status == 'open'
      end 
    end
    sorted.first
  end

end
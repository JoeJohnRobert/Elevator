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
    self.set_all_elevator_directions
    sorted = self.elevators.sort_by {|elevator| (elevator.current_floor - destination.floor).abs}
    sorted.reject! {|elevator| elevator.status == 'closed'} 
    if destination.direction == 'up'
      find_up(sorted, destination) 
    else 
      find_down(sorted, destination) 
    end 
  end

  def find_up(sorted_elevators, destination) 
    sorted_elevators.select! {|elevator| elevator.destination_requests.empty? || elevator.direction == 'up' && elevator.current_floor < destination.floor}
    if sorted_elevators.empty?
      next_best_elevator(destination)
    else
      sorted_elevators.first
    end
  end

  def find_down(sorted_elevators, destination)
    sorted_elevators.select! {|elevator| elevator.destination_requests.empty? || elevator.direction == 'down' && elevator.current_floor > destination.floor}
    if sorted_elevators.empty?
      next_best_elevator(destination)
    else
      sorted_elevators.first
    end
  end

  def next_best_elevator(destination)
    self.elevators.sort_by {|elevator| (elevator.destination_requests.last - destination.floor).abs}.first
  end

  def set_all_elevator_directions
    self.elevators.each {|elevator| elevator.set_direction}
  end
end
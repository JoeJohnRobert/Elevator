require_relative 'elevator_code.rb'
require_relative 'elevator_system.rb'
require_relative 'call_request.rb'

describe ControlPanel do

  let(:elevator) {Elevator.new(1)}
  let(:elevator_two) {Elevator.new(2)}
  let(:system) {ControlPanel.new(10, elevator, elevator_two)}

  before do
    elevator.current_floor = 3
    elevator_two.current_floor = 4
  end

  describe '#elevators' do
    it 'has many elevators' do
      expect(system.elevators).to be_kind_of(Array)
    end
    it 'should know how many elevators it has' do 
      expect(system.elevators.count).to eq(2)  
    end
  end 

  describe '#floors' do 
    it 'knows how many floors there are' do
      expect(system.floors).to eq(10)
    end
  end

  describe '#call_requests' do
    it 'should be a collection of requested floors' do
      expect(system.call_requests).to be_kind_of(Array)
    end
  end

  describe '#call' do
    it 'it should add requested floor to the queue' do
      expect{ system.call(5, 'up') }.to change{ system.call_requests.count }.from(0).to(1)
    end
  end  
   
  describe '#dispatch' do
    before do
      system.call(5, 'up')
      system.call(10, 'down')
      elevator.request_destination(4)
      elevator.request_destination(6)
      elevator_two.request_destination(2)
      elevator_two.request_destination(10)
    end
    it 'decreases queue by one elevator' do
      expect{system.dispatch}.to change{system.call_requests.count}.from(2).to(1)
    end
    it 'sends nearest elevator to requested floor' do
      expect{system.dispatch}.to change{elevator_two.current_floor}.from(4).to(5)
    end
  end  

  describe '#nearest_elevator' do 
    before do
      elevator.request_destination(2)
      elevator.request_destination(6)
      elevator_two.request_destination(1)
      elevator_two.request_destination(6)
    end
    
    request = CallRequest.new(5, 'up')

    it 'should find elevator nearest to the request' do
      expect(system.nearest_elevator(request)).to eq(elevator_two)
    end
    it 'should only find active elevators' do 
      elevator_two.status = 'closed'
      expect(system.nearest_elevator(request)).to eq(elevator)
    end
  end
  
  describe '#find_up' do

    before do
      elevator.request_destination(1)
      elevator.request_destination(6)
    end

    request = CallRequest.new(5, 'up')
    
    it 'should find elevators with no destination requests' do
      expect(system.find_up([elevator_two, elevator], request)).to eq(elevator_two)
    end
    it 'should find elevators with destination requests' do
      expect(system.find_up([elevator, elevator_two], request)).to eq(elevator)
    end
    it 'should find next best elevator if none to sort and none going up' do
      elevator.direction = 'down'
      elevator_two.request_destination(10)
      expect(system.find_up([], request)).to eq(elevator_two)
    end
  end

  describe '#find_down' do

    before do
      elevator.request_destination(10)
      elevator.request_destination(1)
      elevator.current_floor = 7
      elevator.direction = 'down'
    end

    request = CallRequest.new(5, 'down')
    
    it 'should find elevators with no destination requests' do
      expect(system.find_down([elevator_two, elevator], request)).to eq(elevator_two)
    end
    it 'should find elevators with destination requests' do
      expect(system.find_down([elevator, elevator_two], request)).to eq(elevator)
    end
    it 'should find next best elevator if none to sort and none going down' do
      elevator.direction = 'up'
      elevator_two.request_destination(10)
      expect(system.find_down([], request)).to eq(elevator_two)
    end
  end  

  describe '#set_all_elevator_directions' do
    before do 
      elevator.request_destination(1)
    end

    it 'should set the directions of all elevators' do
      expect{system.set_all_elevator_directions}.to change{elevator.direction}.from('up').to('down')
    end
  end
  
  describe '#deactivate_all' do
    it 'should change each elevators status to closed and bring them to ground' do
      expect{system.deactivate_all}.to change{elevator.status && elevator_two.status}.from('open').to('closed')
      expect(elevator.current_floor && elevator_two.current_floor).to eq(1)
    end
  end

  describe '#activate_all' do
    before do
      elevator.status = 'closed'
      elevator_two.status = 'closed'
    end
    it 'should change each elevators status to open' do
      expect{system.activate_all}.to change{elevator.status && elevator_two.status}.from('closed').to('open')
    end
  end

  describe '#deactivate_elevator' do
    it 'should change the elevators status to closed' do 
      expect{system.deactivate_elevator(1)}.to change{elevator.status}.from('open').to('closed')
    end
  end

  describe '#re_activate_elevator' do
    before do 
      elevator.status = 'closed'
    end
    it 'should change the elevators status to open' do 
      expect{system.re_activate_elevator(1)}.to change{elevator.status}.from('closed').to('open')
    end
  end
end


describe Elevator do 
  let(:elevator) {Elevator.new(1)}  
  let(:elevator_two) {Elevator.new(2)}  
  let(:system) {ControlPanel.new(10, elevator, elevator_two)}

  before do
    elevator.request_destination(4)
    elevator.request_destination(10)
  end

  describe '#current_floor' do
    it 'its default floor should be 1' do 
      expect(elevator.current_floor).to eq(1)
    end
  end

  describe '#travel' do
    
    it 'should change the current floor to the destination' do
      expect{elevator.travel(4)}.to change{elevator.current_floor}.from(1).to(4)
    end
  end

  describe '#request_destination' do
    it 'should add request to requests queue' do 
      expect{elevator.request_destination(3)}.to change{elevator.destination_requests.count}.from(2).to(3)
    end
    it 'should not allow you to select your current floor' do
      expect(elevator.request_destination(1)).to eq('You are already on floor 1. Please choose a different floor.')
    end
  end

  describe '#complete_request' do

    it 'should change the current floor to that of destination' do
      expect{elevator.complete_request}.to change{elevator.current_floor}.from(1).to(4)
    end

    it 'should remove completed request from requests queue' do
      expect{elevator.complete_request}.to change{elevator.destination_requests.count}.from(2).to(1) 
      expect(elevator.destination_requests).not_to include(4)
    end
  end

  describe '#nearest_destination' do 
    it 'should find the nearest destination request' do
      expect(elevator.nearest_destination).to eq(4)
    end
  end

  describe '#deactivate' do
    it 'should change elevator status to closed' do
      expect{elevator.deactivate}.to change{elevator.status}.from('open').to('closed')
    end
  end

  describe '#re_activate' do
    before do
      elevator.status = 'closed'
    end
    it 'should change elevator status to open' do
      expect{elevator.re_activate}.to change{elevator.status}.from('closed').to('open')
    end
  end

  describe '#set_direction' do 
    
    before do
      elevator.request_destination(10)
      elevator_two.request_destination(1)
    end 

    it 'should set to up if nearest destination greater than current floor' do 
      elevator.direction = 'down'
      expect{elevator.set_direction}.to change{elevator.direction}.from('down').to('up')
    end
    it 'should set to down if nearest destination less than current floor' do 
      elevator_two.current_floor = 4   
      expect{elevator_two.set_direction}.to change{elevator_two.direction}.from('up').to('down')
    end
  end

  describe '#toggle_direction' do
    
    before do 
      elevator_two.direction = 'down'
    end

    it 'should toggle the elevators direction' do
      expect{elevator.toggle_direction}.to change{elevator.direction}.from('up').to('down')
      expect{elevator_two.toggle_direction}.to change{elevator_two.direction}.from('down').to('up')
    end
  end

end

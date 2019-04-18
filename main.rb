#!/usr/bin/env ruby

require 'readline'

class Slot
  attr_accessor :free_slots, :max_slots, :filled_slots, :parking_order
end

def create_parcel_lot(n)
  initialize_variables
  @slot.max_slots = n
  @slot.filled_slots = []
  @slot.free_slots = (1..n).to_a
  @slot.parking_order = parking_order
  puts "Created a parcel slot with #{n} slots\n"
end

def initialize_variables
  @slot = Slot.new
end

def park(reg_no, weight)
  if @slot.nil?
    puts 'Create slots'
  elsif @slot.free_slots.empty?
    puts "Sorry,parcel slot is full\n"
  else
    slot_no = next_parking_slot
    parking_detail = { slot_number: slot_no, weight: weight, reg_no: reg_no }
    data = Struct.new(*parking_detail.keys).new(*parking_detail.values)
    instance_variable_set("@slot_#{slot_no}", data)
    puts "Allocated slot number: #{slot_no}\n"
  end
end

def next_parking_slot
  free_slots = @slot.free_slots
  @slot.parking_order.each do |slot|
    if free_slots.include?(slot)
      @slot.free_slots.delete(slot)
      return slot
    end
  end
end

def parking_order
  ordered_array = []
  final_slot = @slot.max_slots
  (1..final_slot / 2).each do |n|
    ordered_array << [n, final_slot]
    final_slot -= 1
  end
  ordered_array << @slot.max_slots / 2 + 1 if @slot.max_slots.odd?
  ordered_array.flatten
end

def leave(n)
  instance_variable_set("@slot_#{n}", nil)
  @slot.free_slots << n
  puts "Slot number #{n} is free\n"
end

def status
  puts "Slot No   Registration No   Weight\n"
  active_slots.each do |params|
    puts "#{params.slot_number}   #{params.reg_no}    #{params.weight}\n"
  end
end

def active_slots
  slots_arr = []
  @slot.parking_order.each do |slot|
    slot_params = instance_variable_get("@slot_#{slot}")
    slots_arr << slot_params unless slot_params.nil?
  end
  slots_arr
end

def parcel_code_for_parcels_with_weight(weight)
  collect_and_display('reg_no', 'weight', weight)
end

def slot_numbers_for_parcels_with_weight(weight)
  collect_and_display('slot_number', 'weight', weight)
end

def slot_number_for_registration_number(reg_no)
  collect_and_display('slot_number', 'reg_no', reg_no)
end

def collect_and_display(collect, match, value)
  arr = []
  active_slots.each do |slot|
    arr << slot.send(collect) if slot.send(match) == value
  end
  display_data(arr)
end

def display_data(arr)
  if arr.empty?
    puts "Not found\n"
  else
    puts "#{arr.join(', ')}\n"
  end
end

def similar_methods
  %w(parcel_code_for_parcels_with_weight
     slot_numbers_for_parcels_with_weight
     slot_number_for_registration_number)
end

def execute_commands(line)
  parameters = line.split(' ')
  command = parameters[0]
  case command
  when 'create_parcel_slot_lot', 'create_parking_lot'
    send(:create_parcel_lot, parameters[1].to_i)
  when 'status'
    send(:status)
  when 'leave'
    send(:leave, parameters[1].to_i)
  when 'park'
    send(:park, parameters[1], parameters[2])
  when *similar_methods
    send(command.to_sym, parameters[1])
  else
    puts 'Invalid input command'
  end
end

file_name = ARGV[0]

if file_name.nil?
  loop do
    line = Readline.readline('>>')
    execute_commands(line)
  end
end

File.open(file_name, 'r') do |f|
  f.each_line do |line|
    execute_commands(line)
  end
end

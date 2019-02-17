require 'pry-byebug'
require_relative 'squaregrid.rb'

i = 1
30.times do
  grid_info = {
    size: i,
    max_weight: 20,
    penalty_per_missing_step: 25
  }
  i += 1
  SquareGrid.new(grid_info,"+")
end

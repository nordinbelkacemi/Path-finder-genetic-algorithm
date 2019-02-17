require 'pry-byebug'

class SquareGrid
  attr_reader :size, :grid, :expected_total_weight, :penalty_per_missing_step, :shortest_path_total_length
  def initialize(grid, mode)
    if mode == "+"
      @size = grid[:size]
      @max_weight = grid[:max_weight]
      @grid = Array.new(2 * size + 1)
      @penalty_per_missing_step = grid[:penalty_per_missing_step]
      i = 0
      @grid.each do
        if i.even?
          @grid[i] = Array.new(size) { rand(2..grid[:max_weight]) }
        else
          @grid[i] = Array.new(size + 1) { rand(2..grid[:max_weight]) }
        end
        i += 1
      end

      @shortest_path = Array.new(@size * 2)
      0.upto(@size * 2 - 1).each do |i|
        if i.even?
          @shortest_path[i] = 1
        else
          @shortest_path[i] = 0
        end
      end

      i, j = 0, 0
      @shortest_path.each do |step|
        if step == 1 # MOVE RIGHT
          if j >= @size
            break
          else
            @grid[i][j] = 1
            j += 1
          end
        else # MOVE DOWN
          if i >= 2 * @size
            break
          else
            i += 1
            @grid[i][j] = 1
            i += 1
          end
        end
      end

      @shortest_path_total_length = 2 * @size

      grid_info = "#{grid[:max_weight]},#{grid[:penalty_per_missing_step]}\n"
      @grid.each do |sub_array|
        line = ""
        i = 0
        sub_array.each do |num|
          i != sub_array.size - 1 ? line += "#{num}," : line += "#{num}\n"
          i += 1
        end
        grid_info += line
      end
      File.open("grids/#{grid[:size]}x#{grid[:size]}.txt", "w") do |f|
        f.write(grid_info)
      end
    elsif mode == "load"
      @grid = grid[:grid]
      @size = grid[:size]
      @penalty_per_missing_step = grid[:penalty_per_missing_step]
    end
    # binding.pry()
    @expected_total_weight = 2 * grid[:size] * grid[:max_weight] / 2
  end
end

def load_grid_info(grid_size)
  grid = Hash.new
  grid[:size] = grid_size
  filepath = "grids/#{grid_size}x#{grid_size}.txt"
  File.open(filepath, "r") do |f|
    array = []
    i = 0
    f.each_line do |line|
      if i == 0
        grid[:max_weight] = line.split(",").first.to_i
        grid[:penalty_per_missing_step] = line.split(",").last.to_i
      else
        sub_array = []
        line.split(",").each do |num|
          sub_array << num.to_i
        end
        array << sub_array
      end

      i += 1
    end
    grid[:grid] = array
    grid[:expected_total_weight] = 2 * grid[:size] * grid[:max_weight] / 2
  end
  return grid
end

g = SquareGrid.new({size: 3, max_weight: 20, penalty_per_missing_step: 25}, "+")

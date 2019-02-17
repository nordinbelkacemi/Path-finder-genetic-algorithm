class Grid
  attr_reader :shortest_path

  def initialize
    @shortest_path = Array.new(GRID_SIZE * 2)
    0.upto(GRID_SIZE * 2 - 1).each do |i|
      if i.even?
        @shortest_path[i] = 1
      else
        @shortest_path[i] = 0
      end
    end
  end

  def load_grid_info
    grid = Hash.new

    filepath = "grids/#{GRID_SIZE}x#{GRID_SIZE}.txt"
    File.open(filepath, "r") do |f|
      grid[:grid] = []
      i = 0
      f.each_line do |line|
        if i == 0
          grid[:max_weight] = line.split(",").first.to_i
        else
          sub_array = []
          line.split(",").each do |num|
            sub_array << num.to_i
          end
          grid[:grid] << sub_array
        end
        i += 1
      end
      grid[:expected_total_weight] = 2 * GRID_SIZE * grid[:max_weight] / 2
    end
    return grid
  end

  def zero_grid
    puts "zero_grid"
    grid = Array.new(2 * GRID_SIZE + 1){0}
    k = 0
    grid.each do
      if k.even?
        drawing_grid_helper[k] = Array.new(GRID_SIZE) { 0 }
      else
        drawing_grid_helper[k] = Array.new(GRID_SIZE + 1) { 0 }
      end
      k += 1
    end
  end
end

class Grid
  attr_reader :shortest_path

  def initialize
    @shortest_path = Array.new(GRID_SIZE){[1,0]}.flatten
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
end

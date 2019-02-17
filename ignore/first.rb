require 'pry-byebug'
require 'colorize'
require_relative 'grid.rb'



def scale(total_weight_array, expected_total_weight, exponent)
  scaled_fitness_array = []
  total_weight_array.each do |total_weight|
    scaled_fitness_array << ((expected_total_weight/total_weight.to_f) * 10) ** exponent
  end
  return scaled_fitness_array
end



def scale_and_normalize(total_weight_array, expected_total_weight, exponent)
  normalized_fitness_array = []
  scaled_fitness_array = scale(total_weight_array, expected_total_weight, exponent)
  total = scaled_fitness_array.inject(0, :+)
  scaled_fitness_array.each do |fitness|
    normalized_fitness_array << fitness/total.to_f
  end
  return normalized_fitness_array
end



def draw_path(drawing_grid_helper)
  line = ""
  i = 0
  drawing_grid_helper.each do |row|
    i.even? ? chars = ["◦   ", "◦---", "◦   ◦", "◦---◦"] : chars = ["    ", "|   ", "    ", "|   "]
    j = 0
    row.each do |edge|
      if i == 0 && j == 0
        edge == 1 ? line += "+---" : line += "+   "
      elsif i == drawing_grid_helper.size - 1 && j == row.size - 1
        edge == 1 ? line += "◦---+" : line += "◦   +"
      else
        if j == row.size - 1
          edge == 1 ? line += chars[3] : line += chars[2]
        else
          edge == 1 ? line += chars[1] : line += chars[0]
        end
      end
      j += 1
    end
    i += 1
    line += "\n"
  end
  puts line.green
end



def print_avg_and_min(total_weight_array)
  puts "avg = #{total_weight_array.inject{ |sum, el| sum + el }.to_f / total_weight_array.size}"
  puts "min = #{total_weight_array.min}\n\n"
end



def fitness(path, grid)
  drawing_grid_helper = Array.new(2 * grid.size + 1){0}
  k = 0
  drawing_grid_helper.each do
    if k.even?
      drawing_grid_helper[k] = Array.new(grid.size) { 0 }
    else
      drawing_grid_helper[k] = Array.new(grid.size + 1) { 0 }
    end
    k += 1
  end

  fitness = 0
  failed = false
  info = ""
  i = 0
  j = 0
  path.each do |step|
    if step == 1
      if j >= grid.size
        failed = true
        break
      else
        info += "#{grid.grid[i][j]} "
        drawing_grid_helper[i][j] = 1
        fitness += grid.grid[i][j]
        j += 1
      end
    else
      if i >= 2 * grid.size
        failed = true
        break
      else
        i += 1
        info += "#{grid.grid[i][j]} "
        drawing_grid_helper[i][j] = 1
        fitness += grid.grid[i][j]
        i += 1
      end
    end
  end

  penalty = (grid.size * 2 - j - (i / 2)) * grid.penalty_per_missing_step
  fitness += penalty if failed

  failed ? info += " + #{penalty}  =>  #{fitness}*" : info += "  =>  #{fitness}"
  # puts info
  return [fitness, drawing_grid_helper]
end



def normalized_fitnesses_and_total_weights(paths, grid, exponent, sleep)
  fitness_array = []
  failed = false
  paths.each do |path|
    fitness = fitness(path, grid)[0]
    fitness_array << fitness
  end

  sleep(sleep)
  system 'printf "\033c"'
  draw_path(fitness(paths[fitness_array.each_with_index.min[1]], grid)[1])
  print_avg_and_min(fitness_array)

  # print paths
  # puts "\n"
  #
  # print scale_and_normalize(fitness_array, grid.expected_total_weight, exponent)
  # puts "\n"
  normalized_fitness_array = [scale_and_normalize(fitness_array, grid.expected_total_weight, exponent), fitness_array]
end



def uniform_crossover(parents, path_size)
  child = []
  i = 0
  path_size.times do
    child << parents[rand(0..1)][i]
    i += 1
  end
  return child
end



def one_point_crossover(parents, path_size)
  child = []
  splitting_point_index = rand(0..path_size - 2)
  child << parents[0][0..splitting_point_index]
  child << parents[1][(splitting_point_index + 1)..(path_size - 1)]
  return child.flatten
end



def mutate(child_path, mutation_probability)
  mutated_path = []
  if rand <= mutation_probability
    mutation_index = rand(0..(child_path.size - 1))
    i = 0
    child_path.each do |step|
      if i == mutation_index
        mutated_path << 1 - step
      else
        mutated_path << step
      end
      i += 1
    end
    return mutated_path
  else
    return child_path
  end
end



def elite_path(parent_paths, normalized_fitness_array)
  max_fitness_index = normalized_fitness_array.each_with_index.max[1]
  return parent_paths[max_fitness_index]
end



def roulette_select(parent_paths, normalized_fitness_array)
  cumulative_probability_array = [normalized_fitness_array[0]]
  i = 1
  (normalized_fitness_array.size - 1).times do
    cumulative_probability_array << normalized_fitness_array[i] + cumulative_probability_array[i - 1]
    i += 1
  end

  selection_indices = Array.new

  2.times do
    random_num = rand
    (0..cumulative_probability_array.size).each do |i|
      if i == 0
        selection_indices << 0 if random_num <= cumulative_probability_array[i]
      else
        binding.pry() if i == 5
        selection_indices << i if random_num > cumulative_probability_array[i - 1] && random_num <= cumulative_probability_array[i]
      end
    end
  end

  return [parent_paths[selection_indices[0]], parent_paths[selection_indices[1]]]
end



def new_generation_from(parent_paths, normalized_fitness_array, population_size, mutation_probability, crossover)
  child_paths = []
  elite_path = elite_path(parent_paths, normalized_fitness_array)
  child_paths << elite_path
  (population_size - 1).times do
    if crossover == "uniform"
      child_path = uniform_crossover(roulette_select(parent_paths, normalized_fitness_array), parent_paths.first.size)
    elsif crossover == "one point"
      child_path = one_point_crossover(roulette_select(parent_paths, normalized_fitness_array), parent_paths.first.size)
    end
    child_path = mutate(child_path, mutation_probability)
    child_paths << child_path
  end
  return child_paths
end



def build_csv_data(total_weight_array, generation_counter)
  "#{generation_counter},#{total_weight_array.inject{ |sum, el| sum + el }.to_f / total_weight_array.size},#{total_weight_array.min}\n"
end








n = 30 # 146 is best score for 15
population_size = 5
generations = 150
mutation_percentage = 0.5
exponent = 3
crossover = "uniform"
sleep = 0

grid_info = load_grid_info(n)
max_weight = grid_info[:max_weight]
penalty_per_missing_step = grid_info[:penalty_per_missing_step]
grid = SquareGrid.new(grid_info, "load")


#initialize
parent_paths = Array.new(population_size) { Array.new(2 * n) {rand(0..1)} }

data = ""

generation_counter = 1
generations.times do
  normalized_fitness_array = normalized_fitnesses_and_total_weights(parent_paths, grid, exponent, sleep)[0]
  total_weight_array = normalized_fitnesses_and_total_weights(parent_paths, grid, exponent, sleep)[1]
  data += build_csv_data(total_weight_array, generation_counter)
  child_paths = new_generation_from(parent_paths, normalized_fitness_array,
    population_size, mutation_percentage/100.to_f, crossover)
  parent_paths = child_paths
  generation_counter += 1
end



File.open("performance.csv", "w") do |f|
  f.write(data)
end

system "python3 plot.py"

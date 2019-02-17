NUM_GENERATIONS = 100
GRID_SIZE = 10
POPULATION_SIZE = 80
MUTATION_RATE = 0.01
FITNESS_EXPONENT = 1

CROSSOVER_METHOD = "uniform"
# CROSSOVER_METHOD = "one-point"

SELECTION_METHOD = "roulette wheel"
# SELECTION_METHOD = "tournament"
K_INITIAL, K_STEP, K_STEP_THRESHOLD = 3, 1, 30 # constants for tournament selection: specify k at beginning of genetic algorithm (below class definitions)

ANIMATION = false
SLEEP = 0.2

require 'colorize'
require_relative 'grid.rb'

g = Grid.new
GRID = g.load_grid_info
PATH_SIZE = GRID_SIZE * 2

class Path
  attr_accessor :steps

  def initialize(steps = nil)
    if steps.nil?
      @steps = [Array.new(GRID_SIZE){1}, Array.new(GRID_SIZE){0}].flatten.shuffle # twice the grid size is the amount of steps needed to get from upper left to lower right corner
    else
      @steps = correct(steps)
    end
  end

  def correct(steps)
    return steps if steps.count(1) == GRID_SIZE
    i_0 = steps.each_index.select{|i| steps[i] == 0}
    i_1 = steps.each_index.select{|i| steps[i] == 1}
    if i_0.size > GRID_SIZE
      i_0.sample(i_0.size - GRID_SIZE).each do |i|
        steps[i] = 1 - steps[i]
      end
    elsif i_1.size > GRID_SIZE
      i_1.sample(i_1.size - GRID_SIZE).each do |i|
        steps[i] = 1 - steps[i]
      end
    end
    return steps
  end

  def draw_helper
    drawing_grid_helper = Array.new(2 * GRID_SIZE + 1){0}
    k = 0
    drawing_grid_helper.each do
      if k.even?
        drawing_grid_helper[k] = Array.new(GRID_SIZE) { 0 }
      else
        drawing_grid_helper[k] = Array.new(GRID_SIZE + 1) { 0 }
      end
      k += 1
    end

    i, j = 0, 0
    @steps.each do |step|
      if step == 1
        drawing_grid_helper[i][j] = 1
        j += 1
      else # MOVE DOWN
        i += 1
        drawing_grid_helper[i][j] = 1
        i += 1
      end
    end
    return drawing_grid_helper
  end

  def draw_path
    helper_grid = draw_helper
    line = ""
    i = 0
    helper_grid.each do |row|
      i.even? ? chars = ["◦   ", "◦---", "◦   ◦", "◦---◦"] : chars = ["    ", "|   ", "    ", "|   "]
      j = 0
      row.each do |edge|
        if i == 0 && j == 0
          edge == 1 ? line += "+---" : line += "+   "
        elsif i == helper_grid.size - 1 && j == row.size - 1
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

  def total_weight
    grid = GRID[:grid]

    total = 0
    i, j = 0, 0

    @steps.each do |step|
      if step == 1 # MOVE RIGHT
        total += grid[i][j]
        j += 1
      else # MOVE DOWN
        i += 1
        total += grid[i][j]
        i += 1
      end
    end
    return total
  end

  def fitness
    (GRID[:expected_total_weight].to_f * 10 / total_weight.to_f) ** FITNESS_EXPONENT
  end

  def mutate!
    i, j = rand(0...(@steps.size / 2)), rand((@steps.size / 2)..(@steps.size - 1))
    if @steps[i] == @steps[j]
      loop do
        j = rand((@steps.size / 2)..(@steps.size - 1))
        break if @steps[i] != @steps[j]
      end
    end
    @steps[i] = 1 - @steps[i]
    @steps[j] = 1 - @steps[j]
  end
end

class Population

  attr_reader :paths, :fitnesses
  def initialize(paths = nil)
    @fitnesses = []
    if paths.nil?
      @paths = []
    else
      @paths = paths
      @paths.each do |path|
        @fitnesses << path.fitness
      end
    end
  end

  def seed!
    @paths = Array.new(POPULATION_SIZE) { Path.new }
    @paths.each do |path|
      @fitnesses << path.fitness
    end
  end

  def total_fitness
    @fitnesses.inject {|total, value| total + value}
  end

  def avg_fitness
    total_fitness.to_f / @fitnesses.length.to_f
  end

  def max_fitness
    @fitnesses.max
  end

  def elite_path
    @paths.max_by {|path| path.fitness}
  end

  def roulette_wheel_select
    rand_selection = rand(total_fitness)

    total = 0
    @fitnesses.each_with_index do |f, index|
      total += f
      return @paths[index] if total > rand_selection || index == @fitnesses.size - 1
    end
  end

  def tournament_select(k)
    @paths.sample(k).max_by {|path| path.fitness}
  end

  def select(k = nil)
    if k.nil?
      return roulette_wheel_select
    else
      return tournament_select(k)
    end
  end

  def uniform_crossover(two_paths)
    child_steps = []

    0.upto(PATH_SIZE - 1) do |i|
      child_steps << two_paths[rand(0..1)].steps[i]
    end
    child = Path.new(child_steps)
    return child
  end

  def one_point_crossover(two_paths)
    child_steps = []
    splitting_point_index = rand(0..PATH_SIZE - 1) # in order to always split, splitting_point_index + 1 cannot exceed PATH_SIZE - 1, see two lines below
    child_steps << two_paths[0].steps[0..splitting_point_index]
    child_steps << two_paths[1].steps[(splitting_point_index + 1)..(PATH_SIZE - 1)]

    child = Path.new(child_steps.flatten)
    return child
  end

  def crossover(two_paths)
    if CROSSOVER_METHOD == "uniform"
      return uniform_crossover(two_paths)
    elsif CROSSOVER_METHOD == "one-point"
      return one_point_crossover(two_paths)
    end
  end

  def reproduce(k = nil)
    child_paths = []
    child_paths << elite_path

    2.upto(POPULATION_SIZE) do
      if k.nil?
        parent1 = select
        parent2 = select
      else
        parent1 = select(k)
        parent2 = select(k)
      end

      child = crossover([parent1, parent2])

      if rand <= MUTATION_RATE
        child.mutate!
      end

      child_paths << child
    end
    # binding.pry

    children = child_paths
    return children
  end

  def info
    "avg: #{avg_fitness.round(2)}, max: #{max_fitness.round(2)} -> #{elite_path.total_weight}\n"
  end

  def data
    "#{avg_fitness},#{max_fitness}"
  end
end






data = ""

# Genetic algorithm (GA) starts here

population = Population.new
population.seed!

if SELECTION_METHOD == "tournament"
  k = K_INITIAL
else
  k = nil
end

1.upto(NUM_GENERATIONS) do |i|
  k += K_STEP if i % K_STEP_THRESHOLD == 0 unless k + K_STEP > POPULATION_SIZE if !k.nil?
  if ANIMATION
    system "clear"
    population.elite_path.draw_path
  end
  print "#{i}. "
  puts population.info
  data += "#{i},#{population.data}\n"
  children = population.reproduce(k)
  population = Population.new(children)
  sleep(SLEEP) if ANIMATION
end

# GA ends here

solution = population.elite_path.steps
print "solution: #{solution}\n"

if solution == g.shortest_path
  puts "SUCCESS!"
else
  puts "FAILURE."
end


File.open("performance.csv", "w") do |f|
  f.write(data)
end

system "python3 plot.py"

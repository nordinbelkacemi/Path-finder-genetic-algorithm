# Problem
Let there be an n by n square grid, where each edge is given a weight value that is a positive integer. A valid path through the grid consists of moves to the right or downwards and must start from the upper left, ending in the lower right corner of the grid. Implement a genetic algorithm that finds the valid path accumulating the least weight going through the grid.

# Solution
## Setup
Each edge is given a random value between 2 and 20. Each edge on the diagonal path starting with a move to the right is given a value of 1. This is for testing purposes, to be able to distinguish between convergence to the global optimum (the correct answer) or convergence to a local optimum (incorrect answer).
#### 4x4 grid data representation

![4 by 4 grid data representation](https://i.ibb.co/QMQwn4v/grid-representation.jpg)
#### Path data representation
Let a 1 represent a move to the right and a 0 represent a move downwards. On an n by n grid, a valid path consists of 2n moves, half of them being a 1 and the other half a 0.

Example: [1,0,1,0,1,0,1,0] is the bolded path on the 4x4 grid depicted above.
## Genetic algorithm
In general terms, a genetic algorithm (GA) is as follows:

0. Create an initial population of k individuals (paths), call it the 0th generation.
1. Assign a fitness value to each individual, a value that measures how "good" the solution is.
2. Select two individuals (parents) from the population, in a way that individuals with the higher fitness are more likely to be picked.
3. "Combine" the two parents in order to make a new one, in the hopes that the parents' "good" properties get inherited in some way by the child individual.
4. Mutate the child individual every once in a while to see if we find something new and "good"
5. Repeat from step 3 until you have a new population made up of k individuals.
6. This generation is over, create a new one, by repeating from step 1 with the new population as an input, either until you've reached the optimal solution, or until you've reached N generations (could be given by you).
### Methods used and Challenges
#### Uniform crossover
In this method, each bit is chosen from either parent with equal probability.
#### One-point or Single-point crossover
In this method, we cut each parent in two and copy one half of one parent and the other half of the other parent.
#### Mutation
We flip one random bit.
#### Challenges
If we performed these operations blindly, the child paths would not always be valid! With crossover, there is no guarantee that the result will contain exactly the same amount of 1s as the amount of 0s. With mutation, there can never be a valid result, so there needs to be some form of correction.
#### Solutions
Crossover:
We correct the bits at the initialisation step of a new path:
Crossover -> Array of bits
Array of bits -> New path.
In a bit more detail, the correction method checks which digit is in surplus and if none of them are, nothing is done, otherwise needed amount of 1s or 0s are randomly selected and flipped.

Mutation:
We flip one randomly selected 1 and one randomly selected 0

## Results
In my implementation of the GA, I used elitism, which is the unconditional inclusion of the individual with the highest fitness in the next generation. This ensures that the highest fitness in the next generation is always greater than or equal to that of the previous generation (see orange line).

![Fitness plot](https://i.ibb.co/XX9B4PK/screenshot-12.png | width=450)

![Terminal](https://i.ibb.co/brqLhnn/screenshot-13.png | width=450)

This is a 15x15 grid and the GA found the solution on the 61st iteration.

A brute force algorithm would need to check significantly more possible solutions:

Let's stay with our 15x15 grid. The path will be represented by an array of 30 digits. How many possible valid paths are there on this grid?

Half of the 30 digits are 1s, the other half 0s, the question can be formulated as followed:

[\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_,\_]

How many different ways are there to fit 15 1s into 30 spots (not taking order into consideration)?

That is, in how many different ways can I pick 15 spots out of 30, not taking into consideration the order in which we pick them?

The answer is given by the n choose k expression, or the binomial coefficient:

![Binomial coefficient](https://i.ibb.co/nmty764/screenshot-14.png | width=150)

In our case, n = 30 and k = 15, which gives us 30 choose 15 = 155,117,520

The genetic algorithm took 61 iterations, while a brute force  algorithm would have to check 155 million different paths to get to the optimal solution.

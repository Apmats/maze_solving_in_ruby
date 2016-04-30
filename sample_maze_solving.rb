require './lib/maze_solving.rb'

# Let's play around with our maze solving code by running it against a sample and observing the output

# Make a maze out of the sample file

maze = Maze.new("fixture_1.txt")

# Print out the representation, should give us the columns, rows, start and goal as well as the "wall" positions by printing out a hashmap

maze.print_maze

# Get a path for the maze via depth first search

dfs_path = depth_first_search(maze)

if (!dfs_path.nil?) 
    puts 'Found a path via depth first search, here it is:'
    print dfs_path, "\n"
else 
    puts 'Failed to find a path via depth first search'
end

# Get a path for the maze via breadth first search (this should be the fastest path in this case)

bfs_path = breadth_first_search(maze)

if (!bfs_path.nil?) 
    puts 'Found a path via breadth first search, here it is:'
    print bfs_path, "\n"
else 
    puts 'Failed to find a path via breadth first search'
end

# Get a maze walking agent and try to see if the paths are valid

maze_runner = Maze_Runner.new

if (maze_runner.path_from_start_to_goal?(maze, dfs_path))
    puts 'Depth first search gave us a valid path to the goal'
end


if (maze_runner.path_from_start_to_goal?(maze, bfs_path))
    puts 'Breadth first search gave us a valid path to the goal'
end

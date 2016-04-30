# A class to hold all the data we have for a maze
# Create a maze by pointing to a filename, should look like the sample provided under sample_maze.txt
class Maze 
attr_accessor :start
attr_accessor :goal
  def initialize(filename)
    @mazeMap = Hash.new(0)
    row = 0
    col = 0
    cols_in_last_line = -1
    @start = [-1,-1]
    @goal = [-1,-1]
    File.readlines(filename).each do |line|
      col = 0
      line = line.strip
      # Handle each character in the map
      line.each_char do |char|
        if (char=='x')
          @mazeMap[[row,col]] = 1
        elsif (char=='S')
          @start = [row,col]
        elsif (char=='G')
          @goal = [row,col]
        elsif (char!='-')
          raise ArgumentError.new("Only symbols that should be part of the maze map are -, x, S and G.")
        end
        col+=1
      end
      # Make sure every line has the same columns
      if (cols_in_last_line != -1 && cols_in_last_line != col)
        raise ArgumentError.new("Every line should have the same number of columns.")
      end
      cols_in_last_line = col
      row+=1
    end
    @rows = row
    @cols = col
    # Make sure we have both a start and a goal for our maze
    if (@start == [-1,-1] || @goal == [-1,-1]) 
      raise ArgumentError.new("Start and goal both required to be present in the maze")
    end 
  end
  # Util function to print out our maze
  def print_maze
    print "columns ", @cols, " rows ", @rows, "\n"
    print "start ", @start, " goal ", @goal, "\n"
    puts @mazeMap
  end
  # Check whether a position is valid for our agent to be in
  # For a position to be valid, it needs to be within the maze bounds and not be a wall block
  def valid_position?(position)
    if (position[0].between?(0,@rows-1) && position[1].between?(0,@cols-1) && @mazeMap[[position[0],position[1]]] != 1)
      return true
    end
    return false
  end
end

# Utility function, for a grid position it should get us an array containing the adjacent positions to it

def adjacent_positions(position) 
  adjacent_positions = Array.new(4)
  adjacent_positions[0] = [position[0]+1, position[1]]
  adjacent_positions[1] = [position[0], position[1]+1]
  adjacent_positions[2] = [position[0]-1, position[1]]
  adjacent_positions[3] = [position[0], position[1]-1]
  return adjacent_positions
end


# A function to search for a path through the maze by depth first search
# This is the initial function to start off the recursive calls
# we use the fact that an already visited position shouldn't be checked again (as all posible paths from there are either already checked or scheduled for visiting)
# and this way we can make sure to avoid going in circles. Visited positions are marked into a hashmap and any such marked position isn't explored further.

def depth_first_search(maze)
  nodes_visited = Hash.new(0)
  path = Array.new
  # Our recursion returns a boolean value, true if the path is found and placed into the path argument or false if there wasn't a path found
  if (traverse_dfs(maze,maze.start,nodes_visited,path))
    formatted_path = format_path(path)
    return formatted_path
  else 
    return nil
  end
end

# Recursive part of the search, visiting a position involves:
# Adding the position to the current path, marking it as visited, and then trying to visit all adjacent positions one by one
# If after exploring each adjacent position a path to the goal is reached, we propagate the "true" return value upwards
# If none of the adjacent positions end up returning a path to the goal, we remove this current position from the path (since it's not part of a valid path to the goal)
# and finally return false

def traverse_dfs(maze, position, nodes_visited, path)
  path.push(position)
  if (position == maze.goal) 
    return true
  end
  nodes_visited[position] = 1
  # adjacent positions are calculated and then discarded if already visited or not allowed by the maze grid
  adjacent_positions = adjacent_positions(position)
  adjacent_positions.each do |adjacent_position| 
    if (maze.valid_position?(adjacent_position) && nodes_visited[adjacent_position] == 0)
      if (traverse_dfs(maze, adjacent_position, nodes_visited, path)) 
        return true
      end
    end
  end
  path.pop
  return false
end

# Utility function to format the path (an array of integer pairs) that came out of a search in a prettier way

def format_path(path)
  formatted_path = Array.new
  path.each do |position|
    formatted_path.push('(' + position.join(',') + ')')
  end
  return formatted_path.join('->')
end

# A simplified tree node implementation
# A node holds some content, as well as pointing to it's parent and it's children
# Deletion and other functions missing because they're outside of this exercises scope, and in an 
# actual production project a more robust implementation of a tree should be used


class Tree_Node
attr_accessor :parent
attr_accessor :content
  def initialize(content)
    @children = Array.new
    @content = content 
  end
  def insert(node)
    node.parent = self
    @children.push(node)
  end
end

# A function to search for the shortest path through the maze via breadth first search
# Instead of relying on the implicit stack provided via recursion in our other search function
# we use an array of tree nodes as a queue.
# Once again, we use the fact that a visited node shouldn't be explored further.
# Since we're exploring every path at the same time, finding a visited position means we've already made it to that earlier
# and all adjacent nodes are scheduled for visiting or visited already, and from a shorter path as well.
# If we didn't have that as a given we'd end up exponentially adding elements to our queue.

# Because at each figurative "step" of the algorithm we visit all possible positions that are N steps from the start,
# we are guaranteed to find the shorter path to the goal.
# Because of that, however, finding the path takes potentially longer than exploring a route fully before moving to check another one
# as we did in our depth first search.

# The general approach is, starting with the start position, make a tree node for it
# then add that node to a queue.
# Starting from there, until the queue is empty do the following:
# Remove a node from the queue, and for the position contained there make nodes for all adjacent, unvisited and viable positions
# then add those nodes as children to the node removed from the queue, and add them to the queue
# The queue should empty at some point because we're not adding visited elements to it, and if that is the case without finding a path
# then no path could be found. 

def breadth_first_search(maze)
  queued_position_nodes = Array.new
  nodes_visited = Hash.new(0)
  nodes_visited[maze.start] = 1
  #for each possible next position
  root_node = Tree_Node.new(maze.start)
  queued_position_nodes.push(root_node)
  while (!queued_position_nodes.empty?) do
    position_node = queued_position_nodes.shift
    position = position_node.content
    if (position==maze.goal) 
      formatted_path = format_path(path_for_node(position_node))
      return formatted_path
    end
    # adjacent positions are calculated and then discarded if already visited or not allowed by the maze grid
    adjacent_positions = adjacent_positions(position)
    adjacent_positions.each do |adjacent_position|
      adjacent_position_node = Tree_Node.new(adjacent_position)
      position_node.insert(adjacent_position_node)
      if (maze.valid_position?(adjacent_position) && nodes_visited[adjacent_position] == 0)
        nodes_visited[adjacent_position] =1
        queued_position_nodes.push(adjacent_position_node)
      end
    end
  end
  return nil
end

# Utility function to print out a path once the goal is reached.
# Works it's way from the leaf node back to the root, constructing the path and reversing it to print it out.

def path_for_node(node)
  path = Array.new
  while (node.parent != nil) do
    path.push(node.content)
    node = node.parent
  end
  path.push(node.content)
  return path.reverse
end

# Utility function that we can use to sample the above work or build our tests out of
# Attempts to follow a provided path, formatted like the output of our search functions
# returns false if the path is not a valid path from start to goal and returns true 
# if it does lead from the start to the goal through only valid positions on the maze grid

class Maze_Runner
  def path_from_start_to_goal?(maze, path)
    positions = path.split('->')
    positions.map! do |position|
      position = position.delete('()').split(',')
    end
    positions.map! do |position|
      position = [position[0].to_i, position[1].to_i]
    end
    current_position = [-1,-1]
    positions.each_with_index do |position, i|
      # make sure the path starts at the maze's start
      if (i == 0)
        if (position != maze.start)
          return false
        end
      end
      #make sure that every position the path has us move through is a valid position
      if (!maze.valid_position?(position))
        return false
      end
      # make sure that that the next position is a position adjacent to the current one
      # we also check that this isn't the first position we're looking into, because there's no current_position in that case
      if (!adjacent_positions(current_position).include?(position) && i != 0)
        return false
      end
      # make sure the path ends at the maze's goal
      if (i == positions.length)
        if (position != maze.goal)
          return false
        end
      end
      # finally keep the new position we're moving to as the new current_position
      current_position = position
    end
    # if at no point the path failed these checks, then it gets us from the start to the goal
    return true  
  end
end

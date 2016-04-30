require "test/unit"
require "../lib/maze_solving.rb"

class TC_Maze_Solving < Test::Unit::TestCase
  
  # Expect a valid path for a valid solvable map
  def test_dfs_valid_path
    maze = Maze.new("fixtures/fixture_1.txt")
    maze_runner = Maze_Runner.new
    dfs_path = depth_first_search(maze)
    assert_equal(maze_runner.path_from_start_to_goal?(maze, dfs_path), true)
  end
  
  # Expect a valid path for a valid solvable map
  def test_bfs_valid_path
    maze = Maze.new("fixtures/fixture_1.txt")
    maze_runner = Maze_Runner.new
    bfs_path = breadth_first_search(maze)
    assert_equal(maze_runner.path_from_start_to_goal?(maze, bfs_path), true)
  end
  
  # Expect a the sortest path after searching for it via breadth first search
  def test_bfs_shortest_path
    maze = Maze.new("fixtures/fixture_1.txt")
    bfs_path = breadth_first_search(maze)
    assert_equal(bfs_path, '(0,3)->(0,4)->(0,5)->(1,5)->(2,5)->(3,5)->(4,5)')
  end
   
  # Expect no path for an unsolvable map
  def test_dfs_unsolvable_map
    maze = Maze.new("fixtures/fixture_2.txt")
    assert_equal(depth_first_search(maze), nil)
  end
  
  # Expect no path for an unsolvable map
  def test_bfs_unsolvable_map
    maze = Maze.new("fixtures/fixture_2.txt")
    assert_equal(breadth_first_search(maze), nil)
  end
  
  # Expect an argument error for an invalid map
  def test_invalid_symbols_in_map
    assert_raise(ArgumentError) { maze = Maze.new("fixtures/fixture_3.txt") }
  end
  
  # Expect an argument error for an invalid map 
  def test_mismatching_columns_in_map
    assert_raise(ArgumentError) { maze = Maze.new("fixtures/fixture_4.txt") }
  end

end

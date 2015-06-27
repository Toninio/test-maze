#require 'colorize'

# Panagiotakis Antonis
# 02 Dec 2013

# This program solves the maze puzzle, which has been given in the form of text,
# filling the boxes with numbers that correspond to steps towards ending.
# When this process is completed, starts from the ending point and looks for 
# the smallest number around, creating the route that joins the ending with the starting point.

# prompts correct usage
if !ARGV[0]
  puts "USAGE: ruby maze.rb <mazefile.txt>"
  exit
end

# reads the maze file 
begin
  maze = File.open(ARGV[0], 'r') { |f| f.read }
rescue
  puts "Cannot read file."
  exit
end

# constants
START_CHAR   = 'S'
TRACK_MARKER = 'o'
FINISH_CHAR  = 'G'
SPACE_CHAR   = ' '

# movement directions (up, down, left, right)
DIRECTIONS   = [ [0, -1], [0, 1], [1, 0], [-1, 0] ]

row          = 0
col          = 1

# Splits the maze string into an array of arrays of characters.
@maze = maze.split("\n").map { |row| row.split('') }

# prints the maze unsolved
@maze.each do |r|
  puts r.map { |p| p }.join(" ")
end

puts 

# finds start and finish coordinates
startFound  = false
finishFound = false
@maze.each_with_index do |row, rowIndex|
  row.each_with_index do |col, colIndex|
    case col
      when START_CHAR then
        raise 'More than one start' if startFound
        startFound = true
        @startRow = rowIndex
        @startCol = colIndex
      when FINISH_CHAR then 
        raise 'More than one finish' if finishFound
        finishFound = true
        @finishRow = rowIndex
        @finishCol = colIndex
    end
  end
end

# arrays for valid moves and shortest path tracking
visited  = Array.new << [@startRow, @startCol]
solution = Array.new << [@finishRow, @finishCol]

# visit every valid area
visited.each do |v|
  DIRECTIONS.each do |d|
      if @maze[v[row] + d[row]][v[col] + d[col]] == SPACE_CHAR || 
         @maze[v[row] + d[row]][v[col] + d[col]] == @maze[@finishRow][@finishCol] 
          if @maze[v[row]][v[col]] == START_CHAR
              @maze[v[row] + d[row]][v[col] + d[col]] = 1
              visited << [v[row] + d[row],v[col] + d[col]]
          else
              @maze[v[row] + d[row]][v[col] + d[col]] = @maze[v[row]][v[col]] + 1
              visited << [v[row] + d[row],v[col] + d[col]]                    
          end
      end
  end    
end

# solution finder via checking backwords for the shortest path
solution.each do |s|
  found = false
  DIRECTIONS.each do |d|
      if (@maze[s[row] + d[row]][s[col] + d[col]].is_a? Integer) && !found
          if @maze[s[row] + d[row]][s[col] + d[col]] < @maze[s[row]][s[col]]
              solution << [s[row] + d[row],s[col] + d[col]]
              found = true
          end
      end
  end
end

# puts markers on the solution's path
solution.each{ |s| @maze[s[row]][s[col]] = TRACK_MARKER}

# repositions the finish 
@maze[@finishRow][@finishCol] = FINISH_CHAR

# repositions the spaces
@maze.each_with_index do |r, rIndex|
  r.each_with_index do |c, cIndex|
      if @maze[rIndex][cIndex].is_a? Integer 
          @maze[rIndex][cIndex] = SPACE_CHAR
      end
  end
end

# prints the maze solved
@maze.each {|r| puts r.map { |p| p }.join(" ")}

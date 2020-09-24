require_relative 'custom_error'
require_relative 'string'

class Board
  BLANK_COLOR = 30
  COLOR = (31..37).to_a

  attr_reader :locked, :winner

  def initialize
    @grid = (1..7).map { Array.new(6, BLANK_COLOR) }
    @locked = false
    @winner = nil
  end

  def cloned_grid
    @grid.map(&:clone)
  end

  def drop_disc(color_code, col_plus)
    pre_drop_disc_exception(color_code, col_plus)

    col = col_plus - 1
    top_blank = @grid[col].find_index(BLANK_COLOR)

    raise CustomError, "column [#{col_plus}] is full" if top_blank.nil?

    @grid[col][top_blank] = color_code
    return if try_record_winner?(color_code, col, top_blank)

    try_lock?
  end

  def pretty_print
    pretty_print_top
    puts ''

    10.downto(0).each do |j|
      if j.even?
        pretty_print_level(j / 2)
      else
        pretty_print_divider
      end
      puts ''
    end

    pretty_print_bottom
    puts ''

    print ' '
    (1..7).each { |i| print " #{i}  " }
    puts ''
  end

  def self.out_of_bounds?(col, level)
    col.negative? || col > 6 || level.negative? || level > 5
  end

  private

  def pre_drop_disc_exception(color_code, col_plus)
    if @locked
      raise CustomError, 'board is already locked'
    elsif !COLOR.include?(color_code)
      raise CustomError, "color code [#{color_code}] is illegal"
    elsif Board.out_of_bounds?(col_plus - 1, 0)
      raise CustomError, "column [#{col_plus}] is out of bounds"
    end
  end

  def try_lock?
    @grid.each do |col|
      return false if col[5] == BLANK_COLOR
    end

    @locked = true
    true
  end

  def try_record_winner?(color_code, col, level)
    loop do
      break if horizontal_streak(color_code, col, level) >= 4
      break if vertical_streak(color_code, col, level) >= 4
      break if forward_diagonal_streak(color_code, col, level) >= 4
      break if backward_diagonal_streak(color_code, col, level) >= 4

      return false
    end

    @locked = true
    @winner = color_code
    true
  end

  def horizontal_streak(color_code, col, level)
    return streak(color_code, col, level, [-1, 0]) +
           streak(color_code, col + 1, level, [1, 0])
  end

  def vertical_streak(color_code, col, level)
    return streak(color_code, col, level, [0, -1]) +
           streak(color_code, col, level + 1, [0, 1])
  end

  def forward_diagonal_streak(color_code, col, level)
    return streak(color_code, col, level, [-1, -1]) +
           streak(color_code, col + 1, level + 1, [1, 1])
  end

  def backward_diagonal_streak(color_code, col, level)
    return streak(color_code, col, level, [-1, 1]) +
           streak(color_code, col + 1, level - 1, [1, -1])
  end

  def streak(color_code, col, level, direction)
    result = 0
    next_col = col
    next_level = level

    while !Board.out_of_bounds?(next_col, next_level) &&
          @grid[next_col][next_level] == color_code
      result += 1
      next_col += direction[0]
      next_level += direction[1]
    end
    result
  end

  def pretty_print_level(level)
    print "\u2502"
    0.upto(6).each do |col|
      print ' '
      print "\u25cf".colorize(@grid[col][level])
      print ' '
      print "\u2502"
    end
  end

  def pretty_print_top
    print "\u250c"
    6.times do
      3.times { print "\u2500" }
      print "\u252c"
    end
    3.times { print "\u2500" }
    print "\u2510"
  end

  def pretty_print_divider
    print "\u251c"
    6.times do
      3.times { print "\u2500" }
      print "\u253c"
    end
    3.times { print "\u2500" }
    print "\u2524"
  end

  def pretty_print_bottom
    print "\u2514"
    6.times do
      3.times { print "\u2500" }
      print "\u2534"
    end
    3.times { print "\u2500" }
    print "\u2518"
  end
end

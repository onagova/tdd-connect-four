require_relative 'custom_error'
require_relative 'string'

class Board
  BLANK_COLOR = 30
  COLOR = (31..37).to_a
  HIGHLIGHT_BG = 47

  attr_reader :locked, :winner

  def initialize
    @grid = (1..7).map { Array.new(6, BLANK_COLOR) }
    @locked = false
    @winner = nil
    @win_streak = []
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

  def pretty_print_highlight
    cols = cols_at_levels(@win_streak, 5)
    pretty_print_top(cols)
    puts ''

    10.downto(0).each do |j|
      if j.even?
        level = j / 2
        cols = cols_at_levels(@win_streak, level)
        pretty_print_level(level, cols)
      else
        cols = cols_at_levels(@win_streak, (j + 1) / 2, (j - 1) / 2)
        pretty_print_divider(cols)
      end
      puts ''
    end

    cols = cols_at_levels(@win_streak, 0)
    pretty_print_bottom(cols)
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
    streak = nil
    loop do
      streak = horizontal_streak(color_code, col, level)
      break if streak.size >= 4

      streak = vertical_streak(color_code, col, level)
      break if streak.size >= 4

      streak = forward_diagonal_streak(color_code, col, level)
      break if streak.size >= 4

      streak = backward_diagonal_streak(color_code, col, level)
      break if streak.size >= 4

      return false
    end

    @locked = true
    @winner = color_code
    @win_streak = streak
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
    result = []
    next_col = col
    next_level = level

    while !Board.out_of_bounds?(next_col, next_level) &&
          @grid[next_col][next_level] == color_code
      result << [next_col, next_level]
      next_col += direction[0]
      next_level += direction[1]
    end
    result
  end

  def cols_at_levels(coords, *levels)
    coords.select { |coord| levels.include?(coord[1]) }.map { |coord| coord[0] }
  end

  def pretty_print_level(level, highlight_cols = [])
    if highlight_cols.include?(0)
      print "\u2502".colorize_bg(HIGHLIGHT_BG)
    else
      print "\u2502"
    end

    0.upto(6).each do |col|
      print ' '
      print "\u25cf".colorize(@grid[col][level])
      print ' '

      if highlight_cols.include?(col) || highlight_cols.include?(col + 1)
        print "\u2502".colorize_bg(HIGHLIGHT_BG)
      else
        print "\u2502"
      end
    end
  end

  def pretty_print_top(highlight_cols = [])
    if highlight_cols.include?(0)
      print "\u250c".colorize_bg(HIGHLIGHT_BG)
    else
      print "\u250c"
    end

    0.upto(5).each do |col|
      if highlight_cols.include?(col)
        3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
        print "\u252c".colorize_bg(HIGHLIGHT_BG)
      elsif highlight_cols.include?(col + 1)
        3.times { print "\u2500" }
        print "\u252c".colorize_bg(HIGHLIGHT_BG)
      else
        3.times { print "\u2500" }
        print "\u252c"
      end
    end

    if highlight_cols.include?(6)
      3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
      print "\u2510".colorize_bg(HIGHLIGHT_BG)
    else
      3.times { print "\u2500" }
      print "\u2510"
    end
  end

  def pretty_print_divider(highlight_cols = [])
    if highlight_cols.include?(0)
      print "\u251c".colorize_bg(HIGHLIGHT_BG)
    else
      print "\u251c"
    end

    0.upto(5).each do |col|
      if highlight_cols.include?(col)
        3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
        print "\u253c".colorize_bg(HIGHLIGHT_BG)
      elsif highlight_cols.include?(col + 1)
        3.times { print "\u2500" }
        print "\u253c".colorize_bg(HIGHLIGHT_BG)
      else
        3.times { print "\u2500" }
        print "\u253c"
      end
    end

    if highlight_cols.include?(6)
      3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
      print "\u2524".colorize_bg(HIGHLIGHT_BG)
    else
      3.times { print "\u2500" }
      print "\u2524"
    end
  end

  def pretty_print_bottom(highlight_cols = [])
    if highlight_cols.include?(0)
      print "\u2514".colorize_bg(HIGHLIGHT_BG)
    else
      print "\u2514"
    end

    0.upto(5).each do |col|
      if highlight_cols.include?(col)
        3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
        print "\u2534".colorize_bg(HIGHLIGHT_BG)
      elsif highlight_cols.include?(col + 1)
        3.times { print "\u2500" }
        print "\u2534".colorize_bg(HIGHLIGHT_BG)
      else
        3.times { print "\u2500" }
        print "\u2534"
      end
    end

    if highlight_cols.include?(6)
      3.times { print "\u2500".colorize_bg(HIGHLIGHT_BG) }
      print "\u2518".colorize_bg(HIGHLIGHT_BG)
    else
      3.times { print "\u2500" }
      print "\u2518"
    end
  end
end

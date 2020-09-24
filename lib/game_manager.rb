require_relative 'board'

class GameManager
  PLAYER_ONE = { color: 'red', color_code: 31 }.freeze
  PLAYER_TWO = { color: 'green', color_code: 32 }.freeze

  def self.play
    system 'clear'
    board = Board.new
    player = PLAYER_ONE

    until board.locked
      board.pretty_print
      puts ''
      puts "#{player[:color].capitalize}'s turn to drop"

      begin
        col_plus = GameManager.prompt_col_plus
        board.drop_disc(player[:color_code], col_plus)
      rescue CustomError => e
        puts e
        puts 'try again...'
        retry
      end

      player = player == PLAYER_ONE ? PLAYER_TWO : PLAYER_ONE
      system 'clear'
    end

    board.pretty_print
    puts ''
    GameManager.declare_winner(board)
  end

  def self.prompt_col_plus
    print 'Please select a column [1-7]: '
    input = gets.chomp

    if !input.match?(/^[1-7]$/)
      puts '[INVALID INPUT] try again...'
      GameManager.prompt_col_plus
    else
      input.to_i
    end
  end

  def self.declare_winner(board)
    if board.winner.nil?
      puts 'Game over! It\'s a tie!'
      nil
    else
      winner =
        if board.winner == PLAYER_ONE[:color_code]
          PLAYER_ONE
        else
          PLAYER_TWO
        end

      puts "Game over! #{winner[:color].capitalize} wins!"
      winner
    end
  end
end

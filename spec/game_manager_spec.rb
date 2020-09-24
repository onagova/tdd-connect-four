require './lib/game_manager'

describe GameManager do
  let(:p1) { GameManager::PLAYER_ONE }
  let(:p2) { GameManager::PLAYER_TWO }

  describe '.declare_winner' do
    it 'returns nil for a tie' do
      board_dbl = instance_double('Board', winner: nil)
      expect(GameManager.declare_winner(board_dbl)).to be_nil
    end

    it 'returns player one when player one wins' do
      board_dbl = instance_double('Board', winner: p1[:color_code])
      expect(GameManager.declare_winner(board_dbl)).to eql(p1)
    end

    it 'returns player two when player two wins' do
      board_dbl = instance_double('Board', winner: p2[:color_code])
      expect(GameManager.declare_winner(board_dbl)).to eql(p2)
    end
  end
end

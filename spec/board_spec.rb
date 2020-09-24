require './lib/board'

def new_grid
  (1..7).map { Array.new(6, Board::BLANK_COLOR) }
end

describe Board do
  subject { Board.new }
  let(:injecting_grid) { new_grid }
  let(:expected_grid) { new_grid }
  let(:blank) { Board::BLANK_COLOR }
  let(:p1) { Board::COLOR[0] }
  let(:p2) { Board::COLOR[1] }

  describe '#cloned_grid' do
    it 'returns a clone of current grid' do
      injecting_grid[0][0] = 0
      subject.instance_variable_set(:@grid, injecting_grid)

      expect(subject.cloned_grid).to eql(injecting_grid)
      expect(subject.cloned_grid).not_to equal(injecting_grid)
    end
  end

  describe '#drop_disc' do
    it 'places the disc in the correct position when drop into empty column' do
      expected_grid[0][0] = p1

      subject.drop_disc(p1, 1)
      expect(subject.cloned_grid).to eql(expected_grid)
    end

    it 'places the disc in the correct position when drop into partially filled column' do
      injecting_grid[0][0] = p1
      subject.instance_variable_set(:@grid, injecting_grid)

      expected_grid[0][0] = p1
      expected_grid[0][1] = p1

      subject.drop_disc(p1, 1)
      expect(subject.cloned_grid).to eql(expected_grid)
    end

    it 'raises color code error when color_code arg is the same as BLANK_COLOR' do
      expect { subject.drop_disc(blank, 1) }.to raise_error(CustomError)
    end

    it 'raises column out of bounds error when col arg is out of bounds' do
      expect { subject.drop_disc(p1, 0) }.to raise_error(CustomError)
      expect { subject.drop_disc(p1, 8) }.to raise_error(CustomError)
    end

    it 'raises column is full error when drop into filled column' do
      injecting_grid[0] = Array.new(6, p1)
      subject.instance_variable_set(:@grid, injecting_grid)

      expect { subject.drop_disc(p1, 1) }.to raise_error(CustomError)
    end

    it 'raises board if full error when board is full' do
      injecting_grid = (1..7).map { Array.new(6, p1) }
      subject.instance_variable_set(:@grid, injecting_grid)

      expect { subject.drop_disc(p1, 1) }.to raise_error(CustomError)
    end

    it 'raises board is locked error when board is already locked' do
      subject.instance_variable_set(:@locked, true)

      expect { subject.drop_disc(p1, 1) }.to raise_error(CustomError)
    end

    it 'does not lock the board and recodes no winner when end condition is not met' do
      subject.drop_disc(p1, 1)
      expect(subject.locked).to be(false)
      expect(subject.winner).to be_nil
    end

    context 'when end condition is met' do
      it 'locks the board and records winner with horizontal connect four' do
        injecting_grid[0][0] = p1
        injecting_grid[1][0] = p1
        injecting_grid[2][0] = p1
        subject.instance_variable_set(:@grid, injecting_grid)

        subject.drop_disc(p1, 4)
        expect(subject.locked).to be(true)
        expect(subject.winner).to eql(p1)
      end

      it 'locks the board and records winner with vertical connect four' do
        injecting_grid[0][0] = p1
        injecting_grid[0][1] = p1
        injecting_grid[0][2] = p1
        subject.instance_variable_set(:@grid, injecting_grid)

        subject.drop_disc(p1, 1)
        expect(subject.locked).to be(true)
        expect(subject.winner).to eql(p1)
      end

      context 'with diagonal connect four' do
        it 'locks the board and records winner with forward diagonal' do
          injecting_grid[0][0] = p1
          injecting_grid[1][1] = p1
          injecting_grid[2][2] = p1
          injecting_grid[3][0] = p2
          injecting_grid[3][1] = p2
          injecting_grid[3][2] = p2
          subject.instance_variable_set(:@grid, injecting_grid)

          subject.drop_disc(p1, 4)
          expect(subject.locked).to be(true)
          expect(subject.winner).to eql(p1)
        end

        it 'locks the board and records winner with backward diagonal' do
          injecting_grid[0][3] = p1
          injecting_grid[1][2] = p1
          injecting_grid[2][1] = p1
          subject.instance_variable_set(:@grid, injecting_grid)

          subject.drop_disc(p1, 4)
          expect(subject.locked).to be(true)
          expect(subject.winner).to eql(p1)
        end
      end

      it 'locks the board and records no winner with full board' do
        fill = p2
        injecting_grid = (1..7).map do
          (1..6).map do
            fill += 1
            fill
          end
        end

        injecting_grid[6][5] = blank
        subject.instance_variable_set(:@grid, injecting_grid)

        subject.drop_disc(p1, 7)
        expect(subject.locked).to be(true)
        expect(subject.winner).to be_nil
      end
    end
  end

  describe '.out_of_bounds?' do
    it 'returns true for out of bounds column' do
      expect(Board.out_of_bounds?(-1, 0)).to be(true)
      expect(Board.out_of_bounds?(7, 0)).to be(true)
    end

    it 'returns true for out of bounds level' do
      expect(Board.out_of_bounds?(0, -1)).to be(true)
      expect(Board.out_of_bounds?(0, 6)).to be(true)
    end

    it 'returns true for in bounds coordinate' do
      expect(Board.out_of_bounds?(6, 5)).to be(false)
    end
  end
end

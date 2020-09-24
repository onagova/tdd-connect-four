class CustomError < StandardError
  def initialize(msg = 'connect four error')
    super(msg)
  end
end

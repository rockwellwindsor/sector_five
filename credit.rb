# This class handles the credits assigned at the end of the game
class Credit

  attr_reader :y

  # Constants
  SPEED = 1

  def initialize(window, text, x, y)
    @x = x
    @y = @initial_y = y
    @text = text
    @font = Gosu::Font.new(24)
  end

  def move
    @y -= SPEED
  end

  def draw
    @font.draw(@text, @x, @y, 1)
  end

  def reset
    @y = @initial_y
  end
end

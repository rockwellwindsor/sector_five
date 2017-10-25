require 'gosu'
require_relative 'player'
require_relative 'enemy'

# This class is responsible for running the game
class SectorFive < Gosu::Window

  # Constants
  WIDOW_HEIGHT = 600
  WINDOW_WIDTH = 800

  def initialize
    super(WINDOW_WIDTH, WIDOW_HEIGHT)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemy = Enemy.new(self)
  end

  #
  def draw
    @player.draw
    @enemy.draw
  end

  #
  def update
    # Turn the ship left or right with button press
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)

    # Accelerate when the up arrow is pressed
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move

    # Move the enemy
    @enemy.move
  end
end

window = SectorFive.new
window.show

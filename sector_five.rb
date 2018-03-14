require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'

# This class is responsible for running the game
class SectorFive < Gosu::Window

  # Constants
  WIDOW_HEIGHT    = 600
  WINDOW_WIDTH    = 800
  ENEMY_FREQUENCY = 0.05

  def initialize
    super(WINDOW_WIDTH, WIDOW_HEIGHT)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
  end

  #
  def draw
    @player.draw
    @enemies.each do |enemy|
      enemy.draw
    end
    @bullets.each do |bullet|
      bullet.draw
    end
    @explosions.each do |explosion|
      explosion.draw
    end
  end

  #
  def update
    # Turn the ship left or right with button press
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)

    # Accelerate when the up arrow is pressed
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
    # Randomly generate a new enemy to the screen
    if rand < ENEMY_FREQUENCY
      @enemies.push Enemy.new(self)
    end
    # Move the enemy/enemies
    @enemies.each do |enemy|
      enemy.move
    end
    #
    @bullets.each do |bullet|
      bullet.move
    end

    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
        end
      end
    end

    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.finished
    end

    @enemies.dup.each do |enemy|
      if enemy.y > WIDOW_HEIGHT + enemy.radius
        @enemies.delete enemy
      end
    end

    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end
  end
end

window = SectorFive.new
window.show

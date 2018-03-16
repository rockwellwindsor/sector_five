# This class handles the scenes for the game
require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'laser'
require_relative 'blaster'
require_relative 'explosion'
require_relative 'credit'

class SectorFive < Gosu::Window

  # Constants
  WIDOW_HEIGHT    = 600
  WINDOW_WIDTH    = 800
  ENEMY_FREQUENCY = 0.7
  MAX_ENEMIES     = 1000

  def initialize
    super(WINDOW_WIDTH, WIDOW_HEIGHT)
    self.caption = 'Sector Five'
    @background_image = Gosu::Image.new('images/start_screen.png')
    @start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
    @start_music.play(true)
    @scene = :start
  end

  def initialize_game
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @lasers = []
    @blasters = []
    @explosions = []
    @enemies_appeared = 0
    @enemies_destroyed = 0
    @message_font = Gosu::Font.new(28)
    @game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
    @game_music.play(true)
    @explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
    @shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
    @laser_shooting_sound = Gosu::Sample.new('sounds/laser_2.wav')
    @blaster_shooting_sound = Gosu::Sample.new('sounds/blaster.wav')
    @scene = :game # Switch from running the update_start() and update_draw() methods to update_game() and draw_game() 
  end

  def initialize_end(fate)
    case fate
    when :count_reached
      @message = "You made it!  You destroyed #{@enemies_destroyed} ships."
      @message_2 = "and #{1000 - @enemies_destroyed.to_i} reached your base."
    when :hit_by_enemy
      @message = "You collided with an emeny ship and died."
      @message_2 = "But you took #{@enemies_destroyed} of those damn dirty aliens out with you."
    when :off_top
      @message = "You got too close to the enemy MotherShip and have been killed."
      @message_2 = "But you took #{@enemies_destroyed} of those damn dirty aliens out with you."
    end

    @bottom_message = "Press p to play again, or q to quit"
    @message_font = Gosu::Font.new(28)
    @credits = []
    y = 700
    File.open('credits.txt').each do |line|
      @credits.push(Credit.new(self, line.chomp, 100, y))
      y += 30
    end
    @end_music = Gosu::Song.new('sounds/FromHere.ogg')
    @end_music.play(true)
    @scene = :end
  end

  def draw
    case @scene
    when :start
      draw_start
    when :game
      draw_game
    when :end
      draw_end
    end
  end

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end
  #
  def update_game
    # Turn the ship left or right with button press
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    # Accelerate when the up arrow is pressed
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
    # Move Backwards
    @player.go_backwards if button_down?(Gosu::KbDown)
    # Randomly generate a new enemy to the screen
    if rand < ENEMY_FREQUENCY
      @enemies_appeared += 1
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
    #
    @lasers.each do |laser|
      laser.move
    end
    #
    @blasters.each do |blaster|
      blaster.move
    end
    #
    @explosions.each do |explosion|
      explosion.move
    end
    #
    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @enemies_destroyed += 1
          @explosions.push Explosion.new(self, enemy.x, enemy.y, @player.angle)
          @explosion_sound.play
        end
      end
    end
    #
    @enemies.dup.each do |enemy|
      @lasers.dup.each do |laser|
        distance = Gosu.distance(enemy.x, enemy.y, laser.x, laser.y)
        if distance < enemy.radius + laser.radius
          @enemies.delete enemy
          @lasers.delete laser
          @enemies_destroyed += 1
          @explosions.push Explosion.new(self, enemy.x, enemy.y, @player.angle)
          @explosion_sound.play
        end
      end
    end
    #
    @enemies.dup.each do |enemy|
      @blasters.dup.each do |blaster|
        distance = Gosu.distance(enemy.x, enemy.y, blaster.x, blaster.y)
        if distance < enemy.radius + blaster.radius
          @enemies.delete enemy
          @blasters.delete blaster
          @enemies_destroyed += 1
          @explosions.push Explosion.new(self, enemy.x, enemy.y, @player.angle)
          @explosion_sound.play
        end
      end
    end
    #
    @enemies.dup.each do |enemy|
      @explosions.dup.each do |explosion|
        distance = Gosu.distance(enemy.x, enemy.y, explosion.x, explosion.y)
        if distance < enemy.radius + explosion.radius
          @enemies.delete enemy
          @enemies_destroyed += 1
          @explosions.push Explosion.new(self, enemy.x, enemy.y, @player.angle)
        end
      end
    end
    #
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.finished
    end
    #
    @enemies.dup.each do |enemy|
      if enemy.y > WIDOW_HEIGHT + enemy.radius
        @enemies.delete enemy
      end
    end
    #
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
    #
    @lasers.dup.each do |laser|
      @lasers.delete laser unless laser.onscreen?
    end
    #
    @blasters.dup.each do |blaster|
      @blasters.delete blaster unless blaster.onscreen?
    end
    #
    if @enemies_destroyed == 50
      @laser_message = nil
    end
    # Show user Laser 2 text
    if @enemies_destroyed == 100
      @blaster_message = nil
    end
    # Give access to the laser
    if @enemies_destroyed > 50
      if button_down?(Gosu::KbC)
        @lasers.push Laser.new(self, @player.x, @player.y, @player.angle)
        @laser_shooting_sound.play(0.05)
      end
    end
    # Give access to the blaster
    if @enemies_destroyed > 150
      if button_down?(Gosu::KbV)
        @blasters.push Blaster.new(self, @player.x, @player.y, @player.angle)
        @blaster_shooting_sound.play(0.05)
      end
    end
    # Check if the Max number of enemies has appeared
    initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES

    @enemies.each do |en|
      distance = Gosu::distance(en.x, en.y, @player.x, @player.y)
      initialize_end(:hit_by_enemy) if distance < @player.radius + en.radius
    end
    initialize_end(:off_top) if @player.y < -@player.radius
  end
  #
  def update_end
    @credits.each do |credit|
      credit.move
    end
    if @credits.last.y < 150
      @credits.each do |credit|
        credit.reset
      end
    end
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  def draw_start
    @background_image.draw(0,0,0)
  end
  #
  def draw_game
    @player.draw
    @enemies.each do |enemy|
      enemy.draw
    end
    @bullets.each do |bullet|
      bullet.draw
    end
    @lasers.each do |laser|
      laser.draw
    end
    @blasters.each do |blaster|
      blaster.draw
    end
    @explosions.each do |explosion|
      explosion.draw
    end
    # Show use laser text, cancel the text in the method 
    if @enemies_destroyed > 50 && @enemies_destroyed < 150
      @laser_message = "You have aquired lasers (hold down 'c' key)"
      @message_font.draw(@laser_message, 40, 40, 1, 1, 1, Gosu::Color::AQUA)
    end
    # Show use laser text, cancel the text in the method 
    if @enemies_destroyed > 150 && @enemies_destroyed < 250
      @blaster_message = "You have aquired the Blaster (hold down 'v' key)"
      @message_font.draw(@blaster_message, 40, 40, 1, 1, 1, Gosu::Color::RED)
    end
  end
  #
  def draw_end
    clip_to(50, 140, 700, 360) do
      @credits.each do |credit|
        credit.draw
      end
    end
    draw_line(0, 140, Gosu::Color::RED, WINDOW_WIDTH, 140, Gosu::Color::RED)
    @message_font.draw(@message, 40, 40, 1, 1, 1, Gosu::Color::FUCHSIA)
    @message_font.draw(@message_2, 40, 75, 1, 1, 1, Gosu::Color::FUCHSIA)
    draw_line(0, 500, Gosu::Color::RED, WINDOW_WIDTH, 500, Gosu::Color::RED)
    @message_font.draw(@bottom_message, 180, 540, 1, 1, 1, Gosu::Color::AQUA)
  end
  # Start the game on any button press
  def button_down_start(id)
    initialize_game
  end
  #
  def button_down_game(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
      @shooting_sound.play(0.3)
    end
  end
  #
  def button_down_end(id)
    if id == Gosu::KbP
      initialize_game
    elsif id == Gosu::KbQ
      close
    end
  end

  window = SectorFive.new
  window.show
end

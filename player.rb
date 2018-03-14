# This class is responsible for the player object
class Player

  attr_reader :x, :y, :angle, :radius
  
  # Constants
  ROTATION_SPEED = 3
  ACCELERATION = 2
  FRICTION = 0.9

  # Initialize the players ship
  def initialize(window)
    @x = 200
    @y = 200
    @angle = 0
    @image = Gosu::Image.new('images/ship.png')
    @velocity_x = 0
    @velocity_y = 0
    @radius = 20
    @window = window
  end

  #
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  # Turning the ship
  def turn_left
    @angle -= ROTATION_SPEED
  end

  def turn_right
    @angle += ROTATION_SPEED
  end

  def go_backwards
    if @angle == 0
      @y += 5
    elsif @angle == -180 || @angle == -180
      @y -= 5
    elsif @angle < 0 && @angle > -90
      # We are facing the top left of the screen
      @y += 5
      @x += 5
    elsif @angle < 0 && @angle < -90
      # We are facing the bottom left of the screen
      @y -= 5
      @x += 5
    elsif @angle > 0 && @angle < 90
      # We are facing the top right of the screen
      @y += 5
      @x -= 5
    else
      # We are facing the bottom right of the screen
      @y -= 5
      @x -= 5
    end
  end

  # Accelerate the ship
  def accelerate
    @velocity_x += Gosu.offset_x(@angle, ACCELERATION)
    @velocity_y += Gosu.offset_y(@angle, ACCELERATION)
  end

  #
  def move
    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION

    # Keep the ship in the bounds of the window, the window top is excluded from this
    if @x > @window.width - @radius
      @velocity_x = 0
      @x = @window.width - @radius
    end
    if @x < @radius
      @velocity_x = 0
      @x = @radius
    end
    if @y > @window.height - @radius
      @velocity_y = 0
      @y = @window.height - @radius
    end
  end
end

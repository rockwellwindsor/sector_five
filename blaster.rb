# This class is responsible for the blasters objects
class Blaster

  attr_reader :x, :y, :radius
  
  # Constants
  SPEED = 20

  def initialize(window, x, y, angle)
    @x = x
    @y = y
    @direction = angle
    @image = Gosu::Image.new('images/blaster.png')
    @radius = 5
    @window = window
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 1)
  end

  def move
    @x += Gosu.offset_x(@direction, SPEED)
    @y += Gosu.offset_y(@direction, SPEED)
  end

  def onscreen?
    right = @window.width + @radius
    left = -@radius
    top = -@radius
    bottom = @window.height + @radius
    @x > left and @x < right and @y > top and @y < bottom
  end
end

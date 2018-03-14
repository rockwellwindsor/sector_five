# This class handles the explosion object
class Explosion

  attr_reader :x, :y, :radius, :finished

  # Constants
  SPEED = 10

  def initialize(window, x, y, angle)
    @x = x
    @y = y
    @radius = 30
    @direction = angle
    @images = Gosu::Image.load_tiles('images/explosions.png', 60, 60)
    @image_index = 0
    @finished = false
  end

  def draw
    if @image_index < @images.count
      @images[@image_index].draw(@x - @radius, @y - @radius, 2)
      @image_index += 1
    else
      @finished = true
    end
  end

  def move
    @x += Gosu.offset_x(@direction, SPEED)
    @y += Gosu.offset_y(@direction, SPEED)
  end
end

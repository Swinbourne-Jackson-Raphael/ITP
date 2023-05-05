require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

# Instructions:
# Add a shape_x variable in the following (similar to the cycle one)
# that is initialised to zero then incremented by 10 in update.
# Change the draw method to draw a shape (circle or square)
# (50 pixels in width and height) with a y coordinate of 30
# and an x coordinate of shape_x.

WIDTH = 200
HEIGHT = 135
SHAPE_DIM = 50

class GameWindow < Gosu::Window


  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = "Gosu Cycle Example"
    @shape_x = 0 
  end

  def update
    # move shape x to the right 10
    @shape_x += 10

    # move shape x to left side of screen once it moves off the right
    if(@shape_x > WIDTH) 
        @shape_x = 0 - SHAPE_DIM
    end
  end

  def draw
    # draw shape at current shape x position
    Gosu.draw_rect(@shape_x, 30, SHAPE_DIM, SHAPE_DIM, Gosu::Color::BLUE, ZOrder::TOP, mode=:default)
  end
end

window = GameWindow.new
window.show
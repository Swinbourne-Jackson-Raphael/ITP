require 'rubygems'
require 'gosu'
require 'matrix'

require './jacks_math'
require './jacks_shapes'


class CircleCollider
  attr_accessor :radius, :attached_obj

  # Calculate current position using attached obj current pos, direction, and offset.
  def pos
    return @attached_obj.position - (@attached_obj.forward * @offset[0]) - (@attached_obj.right * @offset[1]) - Vector[@radius,@radius]
  end

  def initialize (start_pos, radius, attached_obj)
    @radius = radius
    @attached_obj = attached_obj
    @offset = @attached_obj.position - start_pos
    @debug_img = Gosu::Image.new(Circle.new(@radius))
  end

  def check_collision(other) squared(other.pos[0] - pos[0]) + squared(other.pos[1] - pos[1]) < squared(@radius + other.radius) ? true : false end

  # Draw a red circle representing this collider
  def draw_debug
    @debug_img.draw(pos[0], pos[1], ZOrder::MIDDLE, 1, 1, Gosu::Color::RED)
  end

end

# A complex collider made up of circle colliders.
class Collider
  attr_accessor :circle_colliders

  def initialize (circle_colliders)
    @circle_colliders = circle_colliders
  end

  # Check if any collission of this collider with all circle colliders of the other collider
  def check_collision(other)
    collission = false
    i = 0
    while i < @circle_colliders.length
      j = 0
      while j < other.circle_colliders.length
        return true if @circle_colliders[i].check_collision(other.circle_colliders[j])
        j+=1
      end
      i+=1
    end
    
  end

  # Call the draw debug function of all circle colliders in this collider
  def draw_debug
    i = 0
    while i < @circle_colliders.length
      @circle_colliders[i].draw_debug
      i+=1
    end
  end

end

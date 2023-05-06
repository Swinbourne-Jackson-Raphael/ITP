require 'rubygems'
require 'gosu'
require 'matrix'

require './jacks_math'
require './jacks_shapes'

class PhysicsObject
    attr_accessor :pos, :angle, :velocity
  
    def initialize (start_pos, start_angle)
      @pos = start_pos
      @angle = start_angle
      @velocity = Vector[0,0]
      @info_font = Gosu::Font.new(10)
    end
  
    # Must be called in the main update method
    def update
      @angle = 0 if @angle > 360 || @angle < -360
  
      # update position using velocity
      @pos = Vector[pos[0] + velocity[0], pos[1] + velocity[1]] 
    end
  
    # Draw debug text above the position of this physics object
    def draw_debug_text
      @info_font.draw_text("angle: #{@angle}", @pos[0], @pos[1] + 30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      @info_font.draw_text("velocity: x:#{@velocity[0]}, y#{@velocity[1]}", @pos[0], @pos[1] + 40, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      @info_font.draw_text("angle_rad: #{deg_to_rads(@angle)}", @pos[0], @pos[1] + 50, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    end

    # Return the forward direction of this physics body
    def forward
      return angle_to_dir_vector(deg_to_rads(angle))
    end

    # Return the right direction of this physics body
    def right
      return angle_to_dir_vector(deg_to_rads(angle + 90))
    end
   
end

class CircleCollider
  attr_accessor :radius, :pbody

  # Calculate current position using pbody current pos, direction, and offset.
  def pos
    return @pbody.pos - (@pbody.forward * @offset[0]) - (@pbody.right * @offset[1]) - Vector[@radius,@radius]
  end

  def initialize (start_pos, radius, pbody)

    @radius = radius
    @pbody = pbody
    @offset = start_pos - @pbody.pos
  end


  def check_collision(other) vec2D_distance(pos, other.pos) < @radius + other.radius ? true : false end

  # Draw a red circle representing this collider
  def draw_debug
    p = pos
    img_collider = Gosu::Image.new(Circle.new(@radius));
    img_collider.draw(p[0], p[1], ZOrder::MIDDLE, 1, 1, Gosu::Color::RED)
  end

end

# A complex collider made up of circle colliders.
class Collider
  attr_accessor :pos, :circle_colliders

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

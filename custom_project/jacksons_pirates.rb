require 'rubygems'
require 'gosu'
require 'matrix'

require './math_functions'
require './circle'

class CircleCollider
  attr_accessor :pos, :radius

  def initialize (pos, radius)
    @pos = pos
    @radius = radius
  end

  def check_collision(other)
   
    #vec2D_distance(@pos, other.pos) > @radius ? true : false 
    if vec2D_distance(@pos, other.pos) > @radius + other.radius
      true
    else 
      false
    end

  end

  # Draw a red circle representing this collider
  def draw_debug
    img_collider = Gosu::Image.new(Circle.new(@radius));
    img_collider.draw(pos[0] - @radius, pos[1] - @radius, ZOrder::MIDDLE, 1, 1, Gosu::Color::RED)
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
      int j = 0
      while j < other.circle_colliders.length
        collission = @circle_colliders[i].check_collision(other.circle_colliders[j])
        j+=1
      end
      i+=1
    end
    return collission
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


class PhysicsObject
  attr_accessor :sprite, :pos, :angle, :velocity

  def initialize (sprite, pos, angle)
    @sprite = sprite
    @pos = pos
    @angle = angle
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
 
end

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

# Global constants
WIN_WIDTH = 1240
WIN_HEIGHT = 720

class DemoWindow < Gosu::Window

# GOSU METHODS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Instance variables which need to be accessible. 
  # Read in ﬁles, setup sprites, and the initial game state.
  def initialize()
    super(WIN_WIDTH, WIN_HEIGHT, false)
    @background = Gosu::Color::AQUA
    @ship = PhysicsObject.new(Gosu::Image.new("media/images/ship_sprite.png"), Vector[WIN_WIDTH/2, WIN_HEIGHT/2], 0)
    @cannonballs = Array.new()
    @ship_speed = 0
    @ship_max_speed = 1.5  
  end

  
  def update() 
    @ship.update

    #inputs
    @ship.angle += 0.65 if button_down?(Gosu::KbD)
    @ship.angle -= 0.65 if button_down?(Gosu::KbA)
    @ship_speed += 0.01 if button_down?(Gosu::KbW)
    @ship_speed -= 0.01 if button_down?(Gosu::KbS)
    @ship_speed = @ship_max_speed if @ship_speed > @ship_max_speed
    @ship_speed = 0 if @ship_speed < 0

    # calculate players velocity using its rotation angle and its speed
    @ship.velocity = angle_to_dir_vector(deg_to_rads(@ship.angle)) * @ship_speed

    i = 0
    while i < @cannonballs.length
      @cannonballs[i].update
      i+=1
    end
      
  end
  

  def draw()
    # Draw background color
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)

    # Draw physics objects
    i = 0
    while i < @cannonballs.length
      @cannonballs[i].sprite.draw_rot(@cannonballs[i].pos[0], @cannonballs[i].pos[1], ZOrder::MIDDLE, @cannonballs[i].angle, 0.5, 0.5, 0.08, 0.08)
      i+=1
    end

    # Draw ship
    @ship.sprite.draw_rot(@ship.pos[0], @ship.pos[1], ZOrder::MIDDLE, @ship.angle, 0.5, 0.5, 0.08, 0.08)
    @ship.draw_debug_text
  end

  def fireCannons(port_or_starboard)
    cb_speed = 10;
    cannonball = PhysicsObject.new(Gosu::Image.new("media/images/cannonball_sprite.png"), Vector[@ship.pos[0], @ship.pos[1]], 0,)
    cannonball.velocity = angle_to_dir_vector(deg_to_rads(@ship.angle + 90 * port_or_starboard)) * cb_speed + @ship.velocity
    @cannonballs << cannonball
  end

  # Button events
  def button_down(id)
    case id
    when Gosu::MsLeft
      fireCannons(-1)
    when Gosu::MsRight
      fireCannons(1)
    when Gosu::KbSpace
      fireCannons(-1)
      fireCannons(1)
    end 
  end

end
DemoWindow.new.show()
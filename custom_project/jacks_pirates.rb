require 'rubygems'
require 'gosu'
require 'matrix'

require './jacks_math'
require './jacks_physics'
require './jacks_shapes'

# A gameobject class containing necessary code to create a game object.
class GameObject

  attr_accessor :sprite, :z_order

  def initialize (sprite, z_order)
      @sprite = sprite
      @z_order = z_order
      @cb_sprite = Gosu::Image.new("media/images/cannonball_sprite.png")
  end

  def update
    fail NotImplementedError, "A GameObject class must implement update!"
  end

  def draw
    fail NotImplementedError, "A GameObject class must implement draw!"
  end

end

class Ship < GameObject

  attr_reader :pbody, :collider, :cannonballs

  def initialize (sprite, physics_body, z_order)
      super(sprite, z_order)

      @pbody = physics_body

      #Create collider here
      c_colliders = Array.new()
      c_colliders << CircleCollider.new(@pbody.pos, 15, @pbody)
      c_colliders << CircleCollider.new(@pbody.pos - Vector[15, 0], 13, @pbody)
      c_colliders << CircleCollider.new(@pbody.pos - Vector[-15, 0], 13, @pbody)
      @collider = Collider.new(c_colliders)

      @cannonballs = Array.new()
  end

  # Called in the main update method
  def update
    @pbody.update
    

    i = 0
    while i < @cannonballs.length
      @cannonballs[i].update
      i+=1
    end
  end

  # Called in the main draw method
  def draw
    # Draw ship
    @sprite.draw_rot(@pbody.pos[0], @pbody.pos[1], ZOrder::MIDDLE, @pbody.angle, 0.5, 0.5, 0.08, 0.08)
    #@pbody.draw_debug_text
    #@collider.draw_debug

    # Draw ships cannonballs
    i = 0
    while i < @cannonballs.length
      @cannonballs[i].draw
      i+=1
    end
  end

  def fireCannons(port_or_starboard)
    cb_speed = 10;
    cb_pb = PhysicsObject.new(Vector[@pbody.pos[0], @pbody.pos[1]], 0,)
    cb = Cannonball.new(@cb_sprite, cb_pb, ZOrder::MIDDLE)
    cb.pbody.velocity = angle_to_dir_vector(deg_to_rads(@pbody.angle + 90 * port_or_starboard)) * cb_speed + @pbody.velocity
    @cannonballs << cb
  end

end

class Cannonball < GameObject

  attr_reader :pbody, :collider

  def initialize (sprite, physics_body, z_order)
    super(sprite, z_order)

    @pbody = physics_body

    #Create collider
    c_colliders = Array.new()
    c_colliders << CircleCollider.new(@pbody.pos, 5, @pbody)
    @collider = Collider.new(c_colliders)
  end

  # Called in the main update method
  def update
    @pbody.update
  end

  # Called in the main draw method
  def draw
    @sprite.draw_rot(@pbody.pos[0], @pbody.pos[1], ZOrder::MIDDLE, @pbody.angle, 0.5, 0.5, 0.08, 0.08)
    #@pbody.draw_debug_text
    #@collider.draw_debug
  end

  def on_collision
    @pbody.pos = Vector[5000, 5000]
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

    ship_sprite = Gosu::Image.new(Gosu::Image.new("media/images/ship_sprite.png"))
    ship_pb = PhysicsObject.new(Vector[WIN_WIDTH/2, WIN_HEIGHT/2], 0)
    @ship = Ship.new(ship_sprite, ship_pb, ZOrder::MIDDLE)
    @ship_speed = 0
    @ship_max_speed = 1.5  

    ai_ship_pb = PhysicsObject.new(Vector[900, 310], 46)
    @ai_ship = Ship.new(ship_sprite, ai_ship_pb, ZOrder::MIDDLE)

    @collision_buffer = Array.new()
    @collision_buffer << @ship
    @collision_buffer << @ai_ship
  end

  
  def update() 
    @ship.update
    @ai_ship.update

    puts("Ship Collision!") if @ship.collider.check_collision(@ai_ship.collider)

    i = 0
    while i < @ship.cannonballs.length
      if @ship.cannonballs[i].collider.check_collision(@ai_ship.collider)
        puts("Cannonball Collision!")
        @ship.cannonballs[i].on_collision
      end
      i+=1
    end
     

    #inputs
    @ship.pbody.angle += 0.65 if button_down?(Gosu::KbD)
    @ship.pbody.angle -= 0.65 if button_down?(Gosu::KbA)
    @ship_speed += 0.01 if button_down?(Gosu::KbW)
    @ship_speed -= 0.01 if button_down?(Gosu::KbS)
    @ship_speed = @ship_max_speed if @ship_speed > @ship_max_speed
    @ship_speed = 0 if @ship_speed < 0

    # calculate players velocity using its rotation angle and its speed
    @ship.pbody.velocity = angle_to_dir_vector(deg_to_rads(@ship.pbody.angle)) * @ship_speed
  
  end
  

  def draw()
    # Draw background
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)

    # Draw ship
    @ship.draw
    @ai_ship.draw
  end

  # Button events
  def button_down(id)
    case id
    when Gosu::MsLeft
      @ship.fireCannons(-1)
    when Gosu::MsRight
      @ship.fireCannons(1)
    when Gosu::KbSpace
      @ship.fireCannons(-1)
      @ship.fireCannons(1)
    end 
  end

end
DemoWindow.new.show()
require 'rubygems'
require 'gosu'
require 'matrix'

require './circle'

class Vector2
  attr_accessor :x, :y

  def initialize (x, y)
    @x = x
    @y = y
  end
end

class PhysicsObject
  attr_accessor :sprite, :pos, :angle, :angle_rad, :velocity

  def initialize (sprite, pos, angle)
    @sprite = sprite
    @pos = pos
    @angle = angle
    @angle_rad = (3.14159265359/180) * @angle # convert angle to radians
    @velocity = Vector[0,0]
  end

  # Must be called in the main update method
  def update
    # angle constraints
    if @angle > 360
      @angle = 0
    end
    if @angle < -360
      @angle = 0
    end

    # calculate angle in radians
    @angle_rad = (3.14159265359/180) * @angle 

    # update position using velocity
    @pos = Vector[pos[0] + velocity[0], pos[1] + velocity[1]] 
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
    @info_font = Gosu::Font.new(10)
    @ship = PhysicsObject.new(Gosu::Image.new("media/images/ship_sprite.png"), Vector[WIN_WIDTH/2, WIN_HEIGHT/2], 0)
    @cannonballs = Array.new()
    @ship_speed = 0
    @ship_max_speed = 1.5
  end

  
  def update() 
    @ship.update

    if button_down?(Gosu::KbD)
      @ship.angle += 0.65
    end

    if button_down?(Gosu::KbA)
      @ship.angle -= 0.65
    end

    if button_down?(Gosu::KbW)
      @ship_speed += 0.01
    end
    if button_down?(Gosu::KbS)
      @ship_speed -= 0.01
    end
    # speed constraints
    if @ship_speed > @ship_max_speed
      @ship_speed = @ship_max_speed
    end
    if @ship_speed < 0
      @ship_speed = 0
    end

    # calculate ships velocity using its rotation angle and its speed
    @ship.velocity = Vector[Math.cos(@ship.angle_rad) * @ship_speed, Math.sin(@ship.angle_rad) * @ship_speed]

    i = 0
    while i < @cannonballs.length
      @cannonballs[i].update
      i+=1
    end
      
  end
  

  def draw()
    # Draw background color
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)

    # Draw ship
    @ship.sprite.draw_rot(@ship.pos[0], @ship.pos[1], ZOrder::MIDDLE, @ship.angle, 0.5, 0.5, 0.08, 0.08)

    i = 0
    while i < @cannonballs.length
      @cannonballs[i].sprite.draw_rot(@cannonballs[i].pos[0], @cannonballs[i].pos[1], ZOrder::MIDDLE, @cannonballs[i].angle, 0.5, 0.5, 0.08, 0.08)
      i+=1
    end

    # Display the ship info
    @info_font.draw_text("ship_angle: #{@ship.angle}", 10, 650, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @info_font.draw_text("ship_velocity: x:#{@ship.velocity[0]}, y#{@ship.velocity[1]}", 10, 670, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @info_font.draw_text("ship_angle_rad: #{@ship.angle_rad}", 10, 690, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)

  end

  def fireCannons(port_or_starboard)

    cb_speed = 10;

    
    shootLeft = 1
    if (@ship.velocity[0] < 0)
      shootLeft = -1    
    else
      shootLeft = 1
    end

    ship_x_vel = @ship.velocity[0]
    ship_y_vel = @ship.velocity[1] 

    # The following equations are scary looking but essentially:
    # Velocity of cannonball relative to ship calculated using the dot product. (If dot product is 0 then the vector is perpendicular)
    # Dot product function broken down to solve for 0 and then substituted to get the x and y velocity of the cannonball (relative to ship).
    # Velocity of cannonball relative to world = velocity of ball relative to ship + velocity of ship relative to world.

    # Calculate y velocity of cannonball relative to ship.
    y2 = Math.sqrt((cb_speed * cb_speed)/(1 + ((ship_y_vel * ship_y_vel)/(ship_x_vel * ship_x_vel))))

    # Calculate x velocity of cannonball relative to ship.
    x2 = -((ship_y_vel * y2)/ship_x_vel)

    # Calculate cannonball velocity relative to world
    cv = (Vector[x2, y2] * shootLeft * port_or_starboard + @ship.velocity)

    cannonball = PhysicsObject.new(Gosu::Image.new("media/images/cannonball_sprite.png"), Vector[@ship.pos[0], @ship.pos[1]], 0,)
    cannonball.velocity = cv
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

  

# CUSTOM METHODS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


end

DemoWindow.new.show()
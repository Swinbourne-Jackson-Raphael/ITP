require 'rubygems'
require 'gosu'
require 'matrix'

require './jacks_math'
require './jacks_physics'
require './jacks_shapes'
require './jacks_game_object.rb'


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

    @game_obj_buffer = Array.new()

    ship_sprite = Gosu::Image.new(Gosu::Image.new("media/images/ship_sprite.png"))
    @ship = Ship.new(ship_sprite, Vector[0.08,0.08], ZOrder::MIDDLE, Vector[WIN_WIDTH/2, WIN_HEIGHT/2], 0, Vector[0,0], @game_obj_buffer)
    @ai_ship = Ship.new(ship_sprite, Vector[0.08,0.08], ZOrder::MIDDLE, Vector[900, 310], 46, Vector[0,0], @game_obj_buffer)

    @game_obj_buffer << @ship
    @game_obj_buffer << @ai_ship

    @ship_speed = 0
    @ship_max_speed = 1.5  

    @info_font = Gosu::Font.new(10)
  end

  
  def update() 

    # Call the update method of all game objects in the game object buffer
    i = 0
    while i < @game_obj_buffer.length
      @game_obj_buffer[i].update()
      j = i+1
      while j < @game_obj_buffer.length
        obj = @game_obj_buffer[i]
        other = @game_obj_buffer[j]
        collision = obj.collider.check_collision(other.collider)
        if collision
          puts("Collision! between collider at |x:#{collision.collider_1.pos[0].floor} y:#{collision.collider_1.pos[1].floor} r: #{collision.collider_1.radius}| & |x:#{collision.collider_2.pos[0].floor} y:#{collision.collider_2.pos[1].floor} r:#{collision.collider_2.radius}|  distance: #{vec2D_distance(collision.collider_1.pos, collision.collider_2.pos).floor(2)}")
          collision.collider_1.debug_colour = Gosu::Color::GREEN
          collision.collider_2.debug_colour = Gosu::Color::GREEN
          obj.on_collision(collision)
          other.on_collision(collision)
        end
        
        j+=1
      end
      i+=1
    end


    # PLAYER SHIP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    @ship.rotation += 0.65 if button_down?(Gosu::KbD)
    @ship.rotation -= 0.65 if button_down?(Gosu::KbA)
    @ship_speed += 0.01 if button_down?(Gosu::KbW)
    @ship_speed -= 0.01 if button_down?(Gosu::KbS)
    @ship_speed = @ship_max_speed if @ship_speed > @ship_max_speed
    @ship_speed = 0 if @ship_speed < 0
    @ship.velocity = @ship.forward * @ship_speed
  
  end
  

  def draw()
    # Draw background
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)

    # Call the draw method of all game objects in the game object buffer
    i = 0
    while i < @game_obj_buffer.length
      @game_obj_buffer[i].draw()
      i+=1
    end

    # Draw fps counter
    @info_font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
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
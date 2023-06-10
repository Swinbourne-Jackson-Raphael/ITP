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

    # Fonts
    @info_font = Gosu::Font.new(10)
    @score_font = Gosu::Font.new(30)
    @game_over_font = Gosu::Font.new(60)

    # Game Parameters
    @background = Gosu::Color::AQUA 
    @number_of_sharks = 10 # max number of sharks on screen

    # Sprites
    @ship_sprite = Gosu::Image.new(Gosu::Image.new("media/images/ship_sprite.png"))
    @shark_sprite = Gosu::Image.new("media/images/shark_sprite.png")

    @game_obj_buffer = Array.new()
    @ship_speed = 0
    @ship_max_speed = 1.5  

    @ship = Ship.new(@ship_sprite, Vector[0.08,0.08], ZOrder::MIDDLE, Vector[WIN_WIDTH/2, WIN_HEIGHT/2], 0, Vector[0,0], @game_obj_buffer, 100)
    @game_obj_buffer << @ship
  end

  
  def update() 

    # Call the update method of all game objects in the game object buffer
    i = 0
    while i < @game_obj_buffer.length
      @game_obj_buffer[i].update()

      # Spawn sharks
      if @game_obj_buffer.length < @number_of_sharks

        # Generate a random position for the shark off screen
        shark_position = nil
        while shark_position.nil? || (shark_position[0] >= 0 && shark_position[0] <= WIN_WIDTH) || (shark_position[1] >= 0 && shark_position[1] <= WIN_HEIGHT)
          x = rand(-300..(WIN_WIDTH + 200))
          y = rand(-300..(WIN_HEIGHT + 200))
          shark_position = Vector[x, y]
        end
        shark = Shark.new(@shark_sprite, Vector[0.3, 0.3], ZOrder::MIDDLE, shark_position, 0, Vector[0, 0], @game_obj_buffer, @ship, rand(1..2))
        @game_obj_buffer << shark
      end

      # Check for collisions between this object and all other objects in the buffer
      j = i+1
      while j < @game_obj_buffer.length
        obj = @game_obj_buffer[i]
        other = @game_obj_buffer[j]
        collision = obj.collider.check_collision(other.collider)
        if collision
          collision.collider_1.attached_obj.on_collision(collision)
          collision.collider_2.attached_obj.on_collision(collision)
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

    #Call the draw method of all game objects in the buffer
    i = 0
    while i < @game_obj_buffer.length
      @game_obj_buffer[i].draw()
      #@game_obj_buffer[i].draw_debug() # Uncomment to draw debugging information
      i+=1
    end

    # Draw fps counter
    @info_font.draw_text("FPS: #{Gosu.fps}", 10, 10, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)

    # Draw health bar
    health_bar_width = 400
    health_bar_height = 40
    health_bar_x = (WIN_WIDTH - health_bar_width) / 2
    health_bar_y = WIN_HEIGHT - health_bar_height - 10
    health_percentage = @ship.health.to_f / 100
    health_bar_fill_width = health_percentage * health_bar_width
    Gosu.draw_rect(health_bar_x - 2, health_bar_y - 2, health_bar_width + 4, health_bar_height + 4, Gosu::Color::BLACK, ZOrder::TOP, mode=:default) # outline
    Gosu.draw_rect(health_bar_x, health_bar_y, health_bar_width, health_bar_height, Gosu::Color::RED, ZOrder::TOP, mode=:default)
    Gosu.draw_rect(health_bar_x, health_bar_y, health_bar_fill_width, health_bar_height, Gosu::Color::GREEN, ZOrder::TOP, mode=:default)
    
    # Draw player score
    score_text = "Score: #{@ship.player_score}"
    score_text_width = @score_font.text_width(score_text)
    score_text_height = @score_font.height
    score_text_x = WIN_WIDTH - score_text_width - 10
    score_text_y = WIN_HEIGHT - score_text_height - 10

    @score_font.draw_text(score_text, score_text_x, score_text_y, ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)

    # Draw game over if player dead
    if @ship.health <= 0
      game_over_text = "Game Over"
      game_over_text_width = @game_over_font.text_width(game_over_text)
      game_over_text_height = @game_over_font.height
      game_over_text_x = (WIN_WIDTH - game_over_text_width) / 2
      game_over_text_y = (WIN_HEIGHT - game_over_text_height) / 2
  
      @game_over_font.draw_text(game_over_text, game_over_text_x, game_over_text_y, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
    end

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
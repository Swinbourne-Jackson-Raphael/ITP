require 'rubygems'
require 'gosu'
require 'matrix'

require './jacks_math'
require './jacks_physics'
require './jacks_shapes'


# A gameobject class containing necessary code to create a game object.
class GameObject

    attr_accessor :sprite, :scale, :z_order, :position, :rotation, :velocity, :collider, :game_obj_buffer
  
    def initialize (sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer)
        @sprite = sprite
        @scale = scale
        @z_order = z_order
        @position = start_position
        @rotation = start_rotation
        @velocity = start_velocity
        @info_font = Gosu::Font.new(10)
        @game_obj_buffer = game_obj_buffer
        @collider = generate_collider
    end

    def destroy()
        @game_obj_buffer.delete(self)
    end

    # Automatically generates a collider for this game object based on the sprite size.
    def generate_collider
        c_colliders = Array.new()
        radius = (@scale[0]/2 * @sprite.width).floor
        c_colliders << CircleCollider.new(@position, radius, self)
        return Collider.new(c_colliders, self)
    end
  
    def update
      @position += @velocity
    end
  
    def draw
      @sprite.draw_rot(@position[0], @position[1], @z_order, @rotation, 0.5, 0.5, @scale[0], @scale[1])
      #draw_debug
    end
  
    def draw_debug
        @info_font.draw_text("position: x:#{@position[0].floor(2)}, y:#{@position[1].floor(2)}", @position[0], @position[1] + 30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        @info_font.draw_text("rotation: #{@rotation.floor(2)}°", @position[0], @position[1] + 40, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        @info_font.draw_text("velocity: x:#{@velocity[0].floor(2)}, y:#{@velocity[1].floor(2)}", @position[0], @position[1] + 50, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        @collider.draw_debug

        line_end = @position + right() * 100
        line_end_left = @position - right() * 100
        Gosu.draw_line(@position[0], @position[1], Gosu::Color::RED, line_end[0], line_end[1], Gosu::Color::RED)
        Gosu.draw_line(@position[0], @position[1], Gosu::Color::RED, line_end_left[0], line_end_left[1], Gosu::Color::RED)
        @info_font.draw_text("position: x:#{@position[0].floor(2)}, y:#{@position[1].floor(2)}", @position[0], @position[1] + 30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        @info_font.draw_text("rotation: #{@rotation.floor(2)}°", @position[0], @position[1] + 40, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        @info_font.draw_text("velocity: x:#{@velocity[0].floor(2)}, y:#{@velocity[1].floor(2)}", @position[0], @position[1] + 50, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    end
  
    # Return the forward direction of this gameobject
    def forward
      return angle_to_dir_vector(deg_to_rads(@rotation))
    end
  
    # Return the right direction of this gameobject
    def right
      return angle_to_dir_vector(deg_to_rads(@rotation + 90))
    end

    # Called by the collision system when this object collides with another object.
    def on_collision(collision)

    end
  
  end
  
  class Ship < GameObject
    
    attr_accessor :health, :player_score

    def initialize (sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer, maxHealth)
        super(sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer) 
        @cb_sprite = Gosu::Image.new("media/images/cannonball_sprite.png")
        @health = maxHealth
        @player_score = 0
    end

    def generate_collider
        c_colliders = Array.new()
        c_colliders << CircleCollider.new(@position, 13, self)
        c_colliders << CircleCollider.new(@position - Vector[15, 0], 12, self)
        c_colliders << CircleCollider.new(@position - Vector[-15, 0], 12, self)
        return Collider.new(c_colliders, self)
    end

    def draw 
        super()
    end
  
    def fireCannons(port_or_starboard)
      cb_speed = 10;
      sh = (@sprite.height * @scale[0]).floor - 8
      cb = Cannonball.new(@cb_sprite, Vector[0.08, 0.08], ZOrder::MIDDLE, @position + (right * port_or_starboard * sh), 0, Vector[0,0], game_obj_buffer)
      cb.velocity = right() * port_or_starboard * cb_speed + @velocity
      @game_obj_buffer << cb
    end

    def on_collision(collisions)
      @health -= 10
      
      if health <= 0
        destroy()
      end
    end

  end
  
  class Cannonball < GameObject
  
    def initialize (sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer)
      super(sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer)
    end
  
    def update
      super()
      destroy() if (@position[0] > WIN_WIDTH + 50 || @position[0] < -50) || (@position[1] > WIN_HEIGHT + 50 || @position[1] < -50)
    end
   
    def draw
      super()
    end

    def on_collision(collisions)
      destroy()
    end
  end

  class Shark < GameObject
  
    def initialize(sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer, player, speed)
      super(sprite, scale, z_order, start_position, start_rotation, start_velocity, game_obj_buffer)
      @player = player
      @speed = speed
    end

    def generate_collider
      c_colliders = Array.new()
      c_colliders << CircleCollider.new(@position, 13, self)
      c_colliders << CircleCollider.new(@position - Vector[20, 0], 6, self)
      c_colliders << CircleCollider.new(@position - Vector[-25, 0], 12, self)
      return Collider.new(c_colliders, self)
    end
  
    def update
      # Calculate the direction vector from the shark to the player
      direction_to_player = @player.position - @position
  
      # Calculate the angle between the current forward direction of the shark and the direction to the player
      angle_to_player = dir_vector_to_angle(direction_to_player) - dir_vector_to_angle(forward)
  
      # Calculate the rotation direction (clockwise or counterclockwise) 
      rotation_direction = angle_to_player <=> 0
  
      # Rotate the shark towards the player until the forward direction is aligned
      rotation_speed = 0.5
      @rotation += rotation_speed * rotation_direction

      @velocity = forward * @speed
  
      super() # Call the update method of the base class
    end

    def on_collision(collision)

      # Determine the object that the shark collided with
      if collision.collider_1.attached_obj == self
        other = collision.collider_2.attached_obj
      else
        other = collision.collider_1.attached_obj
      end

      # Give the player a point if the shark is hit with a cannonball
      if other.is_a?(Cannonball)
        @player.player_score += 1
        puts "hit"
      end

      # Destroy unless the other object is a shark
      unless other.is_a?(Shark)
        destroy()
      end

    end
  end
  
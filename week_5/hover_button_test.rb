require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

# Global constants
WIN_WIDTH = 640
WIN_HEIGHT = 400

class DemoWindow < Gosu::Window

  # set up variables and attributes
  def initialize()
    super(WIN_WIDTH, WIN_HEIGHT, false)
    @background = Gosu::Color::WHITE
    @button_font = Gosu::Font.new(20)
    @info_font = Gosu::Font.new(10)
    @locs = [60,60]

    @button_x = 50
    @button_y = 50
    @button_width = 100
    @button_height = 50
    @button_colour = Gosu::Color::GREEN
  end


  # Draw the background, the button with 'click me' text and text showing the mouse coordinates
  def draw()
    # Draw background color
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)

    # Draw the button
    if mouse_over_button(mouse_x, mouse_y) 
      Gosu.draw_rect(@button_x - 2, @button_y - 2, @button_width + 4, @button_height + 4, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    Gosu.draw_rect(@button_x, @button_y, @button_width, @button_height, @button_colour, ZOrder::MIDDLE, mode=:default)
    @button_font.draw_text("Click me", @button_x + 15, @button_y + 15, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)

    # Display the mouse coordinates at bottom of screen
    @info_font.draw_text("mouse_x: #{mouse_x}", 0, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @info_font.draw_text("mouse_y: #{mouse_y}", 100, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
  end

  # this is called by Gosu to see if it should show the cursor (or mouse)
  def needs_cursor?; true; end

  # Returns true if 
  def mouse_over_button(mouse_x, mouse_y)
    if ((mouse_x > @button_x and mouse_x < @button_x + @button_width) and (mouse_y > @button_y and mouse_y < @button_y + @button_height))
      true
    else
      false
    end
  end

  # If the button area (rectangle) has been clicked on change the background color
  def button_down(id)
    case id
    when Gosu::MsLeft
      if mouse_over_button(mouse_x, mouse_y)
        @background = Gosu::Color::YELLOW
      else
        @background = Gosu::Color::WHITE
      end
    end
  end

end

DemoWindow.new.show()

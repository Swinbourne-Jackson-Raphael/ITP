class Button
    attr_reader :x, :y, :width, :height, :text, :text_colour, :background_colour
  
    def initialize(x, y, width, height, text)
      @x = x
      @y = y
      @width = width
      @height = height
      @text = text
      @text_colour = Gosu::Color::BLACK
      @background_colour = Gosu::Color::GRAY
      @font = Gosu::Font.new(20)
    end
  
    def draw
      Gosu.draw_rect(x, y, width, height, @background_colour)
      @font.draw_text(@text, x + 10, y + 10, 0)
    end
  
    def clicked?(mouse_x, mouse_y)
      mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
    end
 end
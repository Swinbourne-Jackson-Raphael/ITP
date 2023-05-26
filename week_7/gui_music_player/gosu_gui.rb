class Button
    attr_reader :x, :y, :width, :height, :text
  
    def initialize(x, y, width, height, text)
      @x = x
      @y = y
      @width = width
      @height = height
      @text = text
      @font = Gosu::Font.new(20)
    end
  
    def draw
      Gosu.draw_rect(x, y, width, height, Gosu::Color::GRAY)
      @font.draw_text(@text, x + 10, y + 10, 0)
    end
  
    def clicked?(mouse_x, mouse_y)
      mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
    end
 end
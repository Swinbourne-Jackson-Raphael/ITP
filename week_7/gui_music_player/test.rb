require 'gosu'

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

class GameWindow < Gosu::Window
    def initialize
        super(640, 480)
        self.caption = 'Button Example'

        @buttons = Array.new()
        @buttons << Button.new(100, 100, 100, 50, 'Button 1')
        @buttons << Button.new(250, 100, 100, 50, 'Button 2')
        @buttons << Button.new(400, 100, 100, 50, 'Button 3')
    end

    def draw
        @buttons.each(&:draw)
    end

    def update
       
    end

    def button_down(id)
        case id
        when Gosu::MsLeft
            check_buttons_clicked?
        end
    end

    def check_buttons_clicked?()
        @buttons.each do |button|
            if button.clicked?(mouse_x, mouse_y)
            puts ("Button #{button.text} clicked!")
            end
        end
    end
end

window = GameWindow.new
window.show
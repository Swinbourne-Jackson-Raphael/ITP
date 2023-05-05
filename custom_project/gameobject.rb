require "rubygems"
require "gosu"

class GameObject

    attr_accessor :pos_x, :pos_y, :width, :height, :sprite

    def initialize (pos_x, pos_y, width, height)
        @pos_x = pos_x
        @pos_y = pos_y
        @width = width
        @height = height
        @sprite = sprite
    end


end
require 'rubygems'
require 'gosu'
require './circle'

# The screen has layers: Background, middle, top
module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

class DemoWindow < Gosu::Window
  def initialize
    super(640, 400, false)
  end

  def draw

    # Sky
    @color_sky = Gosu::Color.argb(255, 60, 180, 235)
    draw_quad(0, 0, Gosu::Color::WHITE, 640, 0, Gosu::Color::WHITE, 0, 400, @color_sky, 640, 400, @color_sky, ZOrder::BACKGROUND)

    # Sun
    @color_sun = Gosu::Color.argb(255, 230, 230, 0)
    @img_sun = Gosu::Image.new(Circle.new(50))
    @img_sun.draw(520, 10, ZOrder::BACKGROUND, 1, 1, @color_sun)

    # Grass
    @color_grass = Gosu::Color.argb(255, 0, 150, 0)
    Gosu.draw_rect(0, 260, 640, 400, @color_grass, ZOrder::MIDDLE, mode=:default)
    @img_hill = Gosu::Image.new(Circle.new(200));
    @img_hill.draw(200, 200, ZOrder::TOP, 1.4, 0.8, @color_grass)
    @img_hill.draw(-100, 240, ZOrder::TOP, 1.6, 0.9, @color_grass)
    
    # Tree
    @color_leaves = Gosu::Color.argb(255, 1, 220, 15)
    @color_brown = Gosu::Color.argb(255, 160, 70, 15)
    Gosu.draw_rect(100, 80, 35, 220, @color_brown, ZOrder::TOP, mode=:default)
    @img_leaves = Gosu::Image.new(Circle.new(50))
    @img_leaves.draw(110, 80, ZOrder::TOP, 1, 1, @color_leaves)
    @img_leaves.draw(30, 70, ZOrder::TOP, 1.2, 1.2, @color_leaves)
    @img_leaves.draw(80, 40, ZOrder::TOP, 1, 1, @color_leaves)

  end
end

DemoWindow.new.show

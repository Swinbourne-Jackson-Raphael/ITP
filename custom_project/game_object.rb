require "rubygems"
require "gosu"
require './jacksons_pirates'

class GameObject

    attr_accessor :sprite, :physics_object

    def initialize (sprite)
        @sprite = sprite
        @physics_object = PhysicsObject.new(sprite, Vector[0,0], 0)
    end


end
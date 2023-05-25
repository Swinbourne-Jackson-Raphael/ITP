require 'rubygems'
require 'gosu'

require './catalogue.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']


class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

# Put your record definitions here
class MusicPlayerMain < Gosu::Window

    def initialize
        super 600, 800
        self.caption = "Music Player"

        catalogue = Catalogue.new("albums.txt")
        catalogue.print
    end

    # Draws the artwork on the screen for all the albums
    def draw_albums albums
        # complete this code
    end

    # Detects if a 'mouse sensitive' area has been clicked on
    def area_clicked(leftX, topY, rightX, bottomY)
        m_x = Gosu.mouse_x
        m_y = Gosu.mouse_y
        m_x >= leftX && m_x <= rightX && m_y >= topY && m_y <= bottomY ? true : false
    end


    # Takes a String title and an Integer ypos
    # You may want to use the following:
    def display_track(title, ypos)
        @track_font.draw(title, TrackLeftX, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
    end


    # Takes a track index and an Album and plays the Track from the Album
    def playTrack(track, album)
        # complete the missing code
        @song = Gosu::Song.new(album.tracks[track].location)
        @song.play(false)
        # Uncomment the following and indent correctly:
        #	end
        # end
    end

    # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
    def draw_background

    end

    # Not used? Everything depends on mouse actions.
	def update
	end

    # Draws the album images and the track list for the selected album
	def draw
		# Complete the missing code
		draw_background
	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0
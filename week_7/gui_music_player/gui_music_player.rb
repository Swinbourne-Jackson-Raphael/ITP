require 'rubygems'
require 'gosu'

require './catalogue.rb'
require './gosu_gui.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']


# Put your record definitions here
class MusicPlayerMain < Gosu::Window

    def initialize
        super 600, 800
        self.caption = "Music Player"

        @track_font = Gosu::Font.new(10)
        @catalogue = Catalogue.new("albums.txt")
        @catalogue.print

        playTrack(1, @catalogue.albums[0])

        @gui_buffer = Array.new()

        draw_album(@catalogue.albums[0], 50, 50, 1)
    end

    # Draws the artwork for a given album at a given position and scale
    def draw_album(album, x, y, s) 
        album.cover.draw(x, y, ZOrder::UI, s, s)
        i = 0
        while i < album.tracks.length

            display_track(album.tracks[i].name, x, y + 500 + (i*10))
            i += 1
        end
    end

    # Draws the artwork on the screen for all the albums
    def draw_albums(albums)

        i = 0
        while i < albums.length
            draw_album(albums[i], 10, 10, 1)
            i += 1
        end
    end

    # Detects if a 'mouse sensitive' area has been clicked on
    def area_clicked(leftX, topY, rightX, bottomY)
        m_x = Gosu.mouse_x
        m_y = Gosu.mouse_y
        m_x >= leftX && m_x <= rightX && m_y >= topY && m_y <= bottomY ? true : false
    end


    # Takes a String title and an Integer ypos
    # You may want to use the following:
    def display_track(title, xpos, ypos)
        @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
    end


    # Takes a track index and an Album and plays the Track from the Album
    def playTrack(track, album)
        # complete the missing code
        @song = Gosu::Song.new(album.tracks[track].location)
        @song.play(false)
    end

    # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
    def draw_background
        draw_quad(0, 0, TOP_COLOR, 600, 0, TOP_COLOR, 0, 800, BOTTOM_COLOR, 600, 800, BOTTOM_COLOR, ZOrder::BACKGROUND)
    end

    # Draws the album images and the track list for the selected album
	def draw
		# Complete the missing code
		draw_background()

        #draw_albums(@catalogue.albums)
        @gui_buffer.each(&:draw)
	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0
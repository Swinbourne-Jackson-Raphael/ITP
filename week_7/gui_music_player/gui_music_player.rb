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
        @selected_album = 0
        #playTrack(1, @catalogue.albums[0] 
    end


    # Takes a track index and an Album and plays the Track from the Album
    def playTrack(track, album)
        @song = Gosu::Song.new(album.tracks[track].location)
        @song.play(false)
    end


    # Detects if a 'mouse sensitive' area has been clicked on
    def area_clicked(leftX, topY, rightX, bottomY)
        m_x = Gosu.mouse_x
        m_y = Gosu.mouse_y
        m_x >= leftX && m_x <= rightX && m_y >= topY && m_y <= bottomY ? true : false
    end


    # Takes a String title and an Integer ypos
    # You may want to use the following:
    def draw_track(title, xpos, ypos)
        @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
    end


    # Draws the artwork for a given album at a given position and scale
    def draw_album(album, x, y, s) 
        cover_img = Gosu::Image.new(album.cover)
        cover_img.draw(x, y, ZOrder::UI, s, s)
        i = 0
        while i < album.tracks.length
            draw_track(album.tracks[i].name, x, y + 520 + (i*20))
            i += 1
        end
    end


    # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
    def draw_background
        draw_quad(0, 0, TOP_COLOR, 600, 0, TOP_COLOR, 0, 800, BOTTOM_COLOR, 600, 800, BOTTOM_COLOR, ZOrder::BACKGROUND)
    end


    # Draws the album images and the track list for the selected album
	def draw
		draw_background()

        if @selected_album == - 1
            # Draw the list of albums
            # draw_albums()
        else
            # Draw the currently selected album
            draw_album(@catalogue.albums[@selected_album], 50, 50, 1)
        end
	end

    
 	def needs_cursor?; true; end


    # Inputs
	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
	    end
	end

end

# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0
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

class MusicPlayerMain < Gosu::Window
  def initialize
    super 600, 800
    self.caption = "Music Player"

    @track_font = Gosu::Font.new(20)
    @album_font = Gosu::Font.new(30)
    @catalogue = Catalogue.new("albums.txt")
    @selected_album = 0
    @playing = false

    @current_track_index = 0
    @current_album = @catalogue.albums[@selected_album]
    @current_track = nil

    load_track(@current_track_index)
  end

  def load_track(index)
    if @current_track
      @current_track.stop
    end

    track = @current_album.tracks[index]
    @current_track = Gosu::Song.new(track.location)
    @current_track.play(true)
  end

  def update
    if @playing && !@current_track.playing?
      if @current_track_index < @current_album.tracks.length - 1
        @current_track_index += 1
        load_track(@current_track_index)
      else
        @playing = false
      end
    end
  end

  def draw_track(title, xpos, ypos)
    @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def draw_album(album, x, y, s)
    cover_img = Gosu::Image.new(album.cover)
    cover_img.draw(x, y, ZOrder::UI, s, s)
    album_title = "#{album.title} - #{album.artist}"
    @album_font.draw_text(album_title, x, y + 520, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)

    album.tracks.each_with_index do |track, index|
      draw_track(track.name, x, y + 570 + (index * 30))
    end
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR, 600, 0, TOP_COLOR, 0, 800, BOTTOM_COLOR, 600, 800, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  def draw
    draw_background

    if @selected_album == -1
      # Draw the list of albums
      # draw_albums()
    else
      # Draw the currently selected album
      draw_album(@current_album, 50, 50, 1)
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      if area_clicked(50, 50, 350, 450)
        @playing = true
      end
    end
  end

  def area_clicked(leftX, topY, rightX, bottomY)
    m_x = mouse_x
    m_y = mouse_y
    m_x >= leftX && m_x <= rightX && m_y >= topY && m_y <= bottomY
  end
end

MusicPlayerMain.new.show if __FILE__ == $0

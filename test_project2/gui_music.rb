require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

module IPrintable
  def print
    raise "Not implemented"
  end
end

class Catalogue
  include IPrintable
  attr_accessor :albums

  def initialize(filepath)
    music_file = File.new(filepath, "r")
    @albums = read_albums(music_file)
    music_file.close
  end

  def get_albums_by_genre(genre)
    @albums.select { |album| GENRE_NAMES[album.genre] == genre }
  end

  def get_album_by_id(id)
    @albums.find { |album| album.id == id }
  end

  def print
    if @albums.empty?
      puts "\nNo albums found."
    else
      @albums.each(&:print)
    end
  end

  private

  def read_track(music_file)
    name = music_file.gets.chomp
    location = music_file.gets.chomp
    Track.new(name, location)
  end

  def read_tracks(music_file)
    count = music_file.gets.to_i
    tracks = []
    count.times do
      track = read_track(music_file)
      tracks << track
    end
    tracks
  end

  def read_album(music_file)
    album_artist = music_file.gets.chomp
    album_title = music_file.gets.chomp
    album_cover = music_file.gets.chomp
    album_genre = music_file.gets.to_i
    tracks = read_tracks(music_file)
    Album.new(album_artist, album_title, album_cover, album_genre, tracks)
  end

  def read_albums(music_file)
    count = music_file.gets.to_i
    albums = []
    count.times do
      album = read_album(music_file)
      albums << album
    end
    albums
  end
end

class Album
  include IPrintable
  attr_accessor :id, :artist, :title, :cover, :genre, :tracks

  def initialize(artist, title, cover, genre, tracks)
    @id = -1
    @artist = artist
    @title = title
    @cover = cover
    @genre = genre
    @tracks = tracks
  end

  def print
    puts "\n-------------------------\nAlbum ID: #{@id}"
    puts "Artist: #{artist}"
    puts "Title: #{title}"
    puts "Genre: #{GENRE_NAMES[genre]}"
    tracks.each_with_index do |track, index|
      puts("-----\nTrack: #{index + 1}")
      track.print
    end
  end
end

class Track
  include IPrintable
  attr_accessor :name, :location

  def initialize(name, location)
    @name = name
    @location = location
  end

  def print
    puts "Name: #{name}"
    puts "Location: #{location}"
  end
end

class MusicPlayerMain < Gosu::Window
  def initialize
    super(600, 800)
    self.caption = "Music Player"

    @track_font = Gosu::Font.new(20)
    @catalogue = Catalogue.new("albums.txt")
    @selected_album = @catalogue.albums[3]
    @current_track_index = nil
    @current_song = nil

    @album_x = 50
    @album_y = 50
    @track_x = 50
    @track_y = 570
  end

  # Plays track at given index of current selected album
  def play_track(track_index)
    return if @selected_album.nil?

    track = @selected_album.tracks[track_index]
    @current_song = Gosu::Song.new(track.location)
    @current_song.play(false)
    @current_track_index = track_index
  end

  # Draws a single track, in yellow if it is the currently playing track
  def draw_track(title, xpos, ypos, playing)
    color = playing ? Gosu::Color::YELLOW : Gosu::Color::WHITE
    @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, color)
  end

  # Draws the artwork of a single album and the tracks below it
  def draw_album(album)
    cover_img = Gosu::Image.new(album.cover)
    cover_img.draw(@album_x, @album_y, ZOrder::UI, 1, 1)
    album.tracks.each_with_index do |track, index|
      ypos = @track_y + index * 30
      playing = @current_track_index == index
      draw_track(track.name, @track_x, ypos, playing)
    end
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR, 600, 0, TOP_COLOR, 0, 800, BOTTOM_COLOR, 600, 800, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  def draw
    draw_background

    if @selected_album.nil?
      # Draw the list of albums
      # Not relevant for distinction task
      # draw_albums()
    else
      # Draw the currently selected album
      draw_album(@selected_album)
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      if @selected_album.nil?
        # Check if an album was clicked. Not relevant for distinction task
        #@catalogue.albums.each_with_index do |album, index|
        #  if area_clicked?(@album_x, @album_y, @album_x + 200, @album_y + 200)
        #    @selected_album = album
        #    break
        #  end
        #end
      else
        # Check if a track was clicked
        @selected_album.tracks.each_with_index do |track, index|
          ypos = @track_y + index * 30
          if area_clicked?(@track_x, ypos, @track_x + 200, ypos + 30)
            play_track(index)
            break
          end
        end
      end
    end
  end

  private

  def area_clicked?(left_x, top_y, right_x, bottom_y)
    mouse_x >= left_x && mouse_x <= right_x && mouse_y >= top_y && mouse_y <= bottom_y
  end
end

MusicPlayerMain.new.show if __FILE__ == $0

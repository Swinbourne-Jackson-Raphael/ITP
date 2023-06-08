require 'rubygems'
require 'gosu'

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

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

SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
ALBUM_WIDTH = 250
ALBUM_HEIGHT = 250
ALBUM_SPACING = 25
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

class MusicPlayerMain < Gosu::Window
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT)
    self.caption = "Music Player"
    initialize_fonts
    initialize_variables
    initialize_positions
    initialize_album_grid
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      handle_left_mouse_button
    end
  end

  def draw
    draw_background
    draw_content
  end

  private

  def initialize_fonts
    @album_font = Gosu::Font.new(30)
    @button_font = Gosu::Font.new(20)
    @track_font = Gosu::Font.new(20)
  end

  def initialize_variables
    @catalogue = Catalogue.new("albums.txt")
    @selected_album = nil
    @current_track_index = nil
    @current_song = nil
  end

  def initialize_positions
    @album_x = 50
    @album_y = 50
    @track_x = 50
    @track_y = 300
  end

  def initialize_album_grid
    available_width = SCREEN_WIDTH - ALBUM_SPACING * 2
    @albums_per_row = available_width / (ALBUM_WIDTH + ALBUM_SPACING)
    @albums_per_column = (SCREEN_HEIGHT - ALBUM_SPACING * 2) / (ALBUM_HEIGHT + ALBUM_SPACING)
  end

  def play_track(track_index)
    return if @selected_album.nil?

    track = @selected_album.tracks[track_index]
    @current_song = Gosu::Song.new(track.location)
    @current_song.play(false)
    @current_track_index = track_index
  end

  def draw_track(title, xpos, ypos, playing)
    color = playing ? Gosu::Color::YELLOW : Gosu::Color::WHITE
    @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, color)
  end
  
  def draw_album(album)
    draw_back_button
    cover_img = Gosu::Image.new(album.cover)
    cover_img.draw(@album_x, @album_y, ZOrder::UI, 0.5, 0.5)
  
    album.tracks.each_with_index do |track, index|
      ypos = @track_y + index * (@track_font.height + 5)
      playing = @current_track_index == index
      draw_track(track.name, @track_x, ypos, playing)
    end
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR, SCREEN_WIDTH, 0, TOP_COLOR, 0, SCREEN_HEIGHT, BOTTOM_COLOR, SCREEN_WIDTH, SCREEN_HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  def draw_content
    if @selected_album.nil?
      draw_album_list
    else
      draw_album(@selected_album)
    end
  end

  def handle_left_mouse_button
    if @selected_album.nil?
      check_album_selection
    else
      check_track_selection
      check_back_button_selection
    end
  end

  def area_clicked?(left_x, top_y, right_x, bottom_y)
    mouse_x >= left_x && mouse_x <= right_x && mouse_y >= top_y && mouse_y <= bottom_y
  end

  def draw_album_list
    albums = @catalogue.albums
    albums.each_with_index do |album, index|
      row = index/@albums_per_row
      column = index % @albums_per_row
      album_xpos = ALBUM_SPACING + column * (ALBUM_WIDTH + ALBUM_SPACING)
      album_ypos = ALBUM_SPACING + row * (ALBUM_HEIGHT + ALBUM_SPACING)
      cover_img = Gosu::Image.new(album.cover)
      cover_img.draw(album_xpos, album_ypos, ZOrder::UI, 0.5, 0.5)
    end
  end

  def check_album_selection
    albums = @catalogue.albums
    albums.each_with_index do |album, index|
      row = index/@albums_per_row
      column = index % @albums_per_row
      album_xpos = ALBUM_SPACING + column * (ALBUM_WIDTH + ALBUM_SPACING)
      album_ypos = ALBUM_SPACING + row * (ALBUM_HEIGHT + ALBUM_SPACING)

      if area_clicked?(album_xpos, album_ypos, album_xpos + ALBUM_WIDTH, album_ypos + ALBUM_HEIGHT)
        @selected_album = album
        break
      end
    end
  end

  def check_track_selection
    @selected_album.tracks.each_with_index do |track, index|
      ypos = @track_y + index * 30
      if area_clicked?(@track_x, ypos, @track_x + 200, ypos + 30)
        play_track(index)
        break
      end
    end
  end

  def draw_back_button
    draw_quad(10, 10, Gosu::Color::GRAY, 80, 10, Gosu::Color::GRAY, 10, 40, Gosu::Color::GRAY, 80, 40, Gosu::Color::GRAY, ZOrder::UI)
    @button_font.draw_text("Back", 20, 15, ZOrder::UI, 1.0, 1.0)
  end

  def check_back_button_selection
    if area_clicked?(10, 10, 80, 40)
      @selected_album = nil
      @current_song.stop unless @current_song.nil?
    end
  end
end

MusicPlayerMain.new.show if __FILE__ == $0

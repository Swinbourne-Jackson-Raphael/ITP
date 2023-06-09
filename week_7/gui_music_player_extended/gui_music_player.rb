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
SCREEN_HEIGHT = 650
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

  def update

    # Update elapsed time if a song is playing
    if @current_song && @current_song.playing?
      @elapsed_time += Gosu::milliseconds / 1000.0
    end
  end
  

  def draw
    draw_background
    draw_content
  end

  private

  # INITIALIZE METHODS
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def initialize_fonts
    @album_font = Gosu::Font.new(35)
    @button_font = Gosu::Font.new(45)
    @info_font = Gosu::Font.new(25)
    @track_font = Gosu::Font.new(20)
  end

  def initialize_variables
    @catalogue = Catalogue.new("albums.txt")
    @current_page = 0
    @selected_album = nil
    @current_track_index = nil
    @current_song = nil
    @elapsed_time = 0
  end

  def initialize_positions
    @album_x = 50
    @album_y = 50
    @track_x = 50
    @track_y = 310
  end

  def initialize_album_grid
    available_width = SCREEN_WIDTH - ALBUM_SPACING * 2
    @albums_per_row = available_width / (ALBUM_WIDTH + ALBUM_SPACING)
    @albums_per_column = (SCREEN_HEIGHT - ALBUM_SPACING * 2) / (ALBUM_HEIGHT + ALBUM_SPACING)
    @rows_per_page = (SCREEN_HEIGHT - 2 * ALBUM_SPACING) / (ALBUM_HEIGHT + ALBUM_SPACING)
    @albums_per_page = @albums_per_row * @rows_per_page
  end

  # ALBUM LIST - UI SCREEN
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # Draws a grid of albums
  def draw_album_list
    albums = @catalogue.albums
    start_index = @current_page * @albums_per_page
    end_index = start_index + @albums_per_page - 1
    albums_to_display = albums[start_index..end_index]

    albums_to_display.each_with_index do |album, index|
      row = index/@albums_per_row
      column = index % @albums_per_row
      album_xpos = ALBUM_SPACING + column * (ALBUM_WIDTH + ALBUM_SPACING)
      album_ypos = ALBUM_SPACING + row * (ALBUM_HEIGHT + ALBUM_SPACING)
      cover_img = Gosu::Image.new(album.cover)
      cover_img.draw(album_xpos, album_ypos, ZOrder::UI, 0.5, 0.5)
    end

    draw_page_navigation
  end

  # Checks if an album has been clicked, opens the album if so
  def check_album_selection
    albums = @catalogue.albums
    start_index = @current_page * @albums_per_page
    end_index = start_index + @albums_per_page - 1
    albums_to_check = albums[start_index..end_index]

    albums_to_check.each_with_index do |album, index|
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

  # Draws two navigation buttons at the bottom of the page to scroll through albums
  def draw_page_navigation
    button_width = 30
    button_height = 30
    navigation_width = 2 * button_width + ALBUM_SPACING
    navigation_x = (SCREEN_WIDTH - navigation_width) / 2 - 20
    button_y = SCREEN_HEIGHT - ALBUM_SPACING - button_height
  
    # Draw backward button
    @button_font.draw_text("<", navigation_x + 10, button_y + 5, ZOrder::UI, 1.0, 1.0)
  
    # Draw forward button
    @button_font.draw_text(">", navigation_x + button_width + ALBUM_SPACING + 10, button_y + 5, ZOrder::UI, 1.0, 1.0)
  end
  
  # Check if the page navigation buttons are clicked
  def check_page_navigation_selection
    button_width = 30
    button_height = 30
    navigation_width = 2 * button_width + ALBUM_SPACING
    navigation_x = (SCREEN_WIDTH - navigation_width) / 2 - 20
    button_y = SCREEN_HEIGHT - ALBUM_SPACING - button_height
    font_x = navigation_x + 10
    
    # Check navigation buttons
    if area_clicked?(navigation_x, button_y, navigation_x + navigation_width, button_y + button_height)
      click_x = mouse_x - font_x
    
      if click_x < button_width
        go_to_previous_page
      elsif click_x > button_width + ALBUM_SPACING
        go_to_next_page
      end
    end
  end

  # Handle page navigation
  def go_to_next_page
    @current_page += 1 if (@current_page + 1) * @albums_per_page < @catalogue.albums.length
  end

  def go_to_previous_page
    @current_page -= 1 if @current_page > 0
  end

  # SELECTED ALBUM - UI SCREEN
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
  # Draws a given album cover, information, and tracklist.
  def draw_album(album)

    # Draw album cover
    draw_back_button
    cover_img = Gosu::Image.new(album.cover)
    cover_img.draw(ALBUM_SPACING, ALBUM_SPACING, ZOrder::UI, 0.5, 0.5)
    
    # Draw album information
    album_info_x = ALBUM_SPACING + ALBUM_WIDTH + ALBUM_SPACING
    album_info_y = ALBUM_SPACING
    @album_font.draw_text(album.title, album_info_x, album_info_y, ZOrder::UI, 1.0, 1.0)
    artist_genre_x = album_info_x
    artist_genre_y = album_info_y + @album_font.height + 5
    artist_genre_text = "#{album.artist} - #{GENRE_NAMES[album.genre]}"
    @info_font.draw_text(artist_genre_text, artist_genre_x, artist_genre_y, ZOrder::UI, 1.0, 1.0)
    
    # Draw white line seperating album info from tracks
    line_x1 = album_info_x
    line_x2 = line_x1 + ALBUM_WIDTH
    line_y = artist_genre_y + @button_font.height + 10
    draw_line(line_x1, line_y, Gosu::Color::WHITE, line_x2, line_y, Gosu::Color::WHITE, ZOrder::UI)

    # Draw tracks
    tracks_x = album_info_x
    tracks_y = line_y + 10
    album.tracks.each_with_index do |track, index|
      track_ypos = tracks_y + index * (@track_font.height + 5)
      playing = @current_track_index == index
      draw_track(track.name, tracks_x, track_ypos, playing)
    end

  end

  # Draws a back button at the bottom left of the screen
  def draw_back_button
    button_width = 70
    button_height = 30
    button_x = ALBUM_SPACING
    button_y = SCREEN_HEIGHT - button_height - ALBUM_SPACING
    @button_font.draw_text(" << ", button_x + 10, button_y + 5, ZOrder::UI, 1.0, 1.0)
  end
  
  # Checks to see if the back button was clicked. If so, go back to the album list
  def check_back_button_selection
    button_width = 70
    button_height = 30
    button_x = ALBUM_SPACING
    button_y = SCREEN_HEIGHT - ALBUM_SPACING - button_height
    font_x = button_x + 10

    if area_clicked?(button_x, button_y, button_x + button_width, button_y + button_height)
      click_x = mouse_x - font_x

      if click_x >= 0 && click_x <= button_width
        @selected_album = nil
        @current_track_index = nil
        @current_song.stop unless @current_song.nil?
      end
    end
  end


  # Draws track title at given position. Draw in yellow if track is playing
  def draw_track(title, xpos, ypos, playing)
    color = playing ? Gosu::Color::YELLOW : Gosu::Color::WHITE
    @track_font.draw_text(title, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, color)
  end

  # Checks to see if any of the tracks were clicked. If so, play the track.
  def check_track_selection
    tracks_y = ALBUM_SPACING + @album_font.height + 5 + @button_font.height + 10 + 10
    @selected_album.tracks.each_with_index do |track, index|
      track_ypos = tracks_y + index * (@track_font.height + 5)
      if area_clicked?(ALBUM_SPACING + ALBUM_WIDTH + ALBUM_SPACING, track_ypos, ALBUM_SPACING + ALBUM_WIDTH + ALBUM_SPACING + ALBUM_WIDTH, track_ypos + @track_font.height)
        play_track(index)
        break
      end
    end
  end

  # OTHER METHODS
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Plays the given track index of the currently selected album
  def play_track(track_index)
    return if @selected_album.nil?
    track = @selected_album.tracks[track_index]
    @current_song = Gosu::Song.new(track.location)
    @current_song.play(false)
    @current_track_index = track_index
  end

  # Draws a background gradient
  def draw_background
    draw_quad(0, 0, TOP_COLOR, SCREEN_WIDTH, 0, TOP_COLOR, 0, SCREEN_HEIGHT, BOTTOM_COLOR, SCREEN_WIDTH, SCREEN_HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  # Determines which UI screen to display based on whether an album is selected
  def draw_content
    if @selected_album.nil?
      draw_album_list
    else
      draw_album(@selected_album)
    end
  end

  # Calls appropriate UI click check methods based on current screen
  def handle_left_mouse_button
    if @selected_album.nil?
      check_album_selection
      check_page_navigation_selection
    else
      check_track_selection
      check_back_button_selection
    end
  end

  # Return true if the given area matches location of mouse
  def area_clicked?(left_x, top_y, right_x, bottom_y)
    mouse_x >= left_x && mouse_x <= right_x && mouse_y >= top_y && mouse_y <= bottom_y
  end
end

MusicPlayerMain.new.show if __FILE__ == $0


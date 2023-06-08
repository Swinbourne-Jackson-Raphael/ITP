require 'rubygems'
require 'gosu'

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

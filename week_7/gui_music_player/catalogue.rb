require 'rubygems'
require 'gosu'

module IPrintable
    def print
      raise "Not implemented"
    end 
end


# Container class for a collection of albums. 
class Catalogue
    include IPrintable
    attr_accessor :albums

    def initialize (filepath)

        # Load the albums stored at given filepath
        music_file = File.new(filepath, "r")
        @albums = read_albums(music_file)
        music_file.close()
    end

    # Returns an array of albums that match given genre
    def get_albums_by_genre(genre) 
        result = Array.new()
        i = 0
        while i < @albums.length()
            if GENRE_NAMES[@albums[i].genre] == genre
                result << @albums[i]
            end          
            i+=1
        end
        return result
    end

    # Returns an album that matches given id
    def get_album_by_id(id)
        found = nil
        i = 0
        while i < @albums.length()
            if @albums[i].id == id
                found = @albums[i]
                i = @albums.length()
            end          
            i+=1
        end
        return found
    end

    # Print an array of albums to the terminal
    def print()
        i = 0
        while i < @albums.length()
            @albums[i].print()
            i+=1
        end
        puts ("\nNo albums found.") if @albums.length < 1
    end

    private

    # Reads in and returns a single track from the given file
    def read_track(music_file)
        name = music_file.gets().chomp()
        location = music_file.gets().chomp()
        track = Track.new(name, location)
        return track
    end
    
    # Returns an array of tracks read from the given file
    def read_tracks(music_file)
        count = music_file.gets().to_i()
        tracks = Array.new()
        i = 0
        while i < count
            track = read_track(music_file)
            tracks << track 
            i += 1
        end
        return tracks
    end

    # Reads in and returns a single album from the given file, with all its tracks
    def read_album(music_file)
        album_artist = artist = music_file.gets().chomp()
        album_title = music_file.gets().chomp()
        album_cover = Gosu::Image.new(music_file.gets().chomp())
        album_genre = music_file.gets().to_i()
        tracks = read_tracks(music_file)
        album = Album.new(album_artist, album_title, album_cover, album_genre, tracks)
        return album
    end

    # Returns an array of albums read from the given file
    def read_albums(music_file)
        count = music_file.gets().to_i()
        albums = Array.new()
        i = 0
        while i < count
            album = read_album(music_file)
            album.id = i
            albums << album 
            i += 1
        end
        return albums
    end
end


class Album
    include IPrintable
    attr_accessor :id, :artist, :title, :cover, :genre, :tracks

    def initialize (artist, title, cover, genre, tracks)
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
        i = 0
        while i < tracks.length
            puts("-----\nTrack: #{i+1}")
            tracks[i].print
            i+=1
        end
    end
end

  
class Track
    include IPrintable
    attr_accessor :name, :location

    def initialize (name, location)
        @name = name
        @location = location
    end

    def print
        puts "Name: #{name}"
        puts "Location: #{location}"
    end
end

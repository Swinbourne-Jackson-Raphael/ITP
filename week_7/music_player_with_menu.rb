require './input_functions'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end
  
$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

module IPrintable
    def print
      raise "Not implemented"
    end 
end

class Album
    include IPrintable
    attr_accessor :artist, :title, :genre, :tracks

    def initialize (artist, title, genre, tracks)
        @artist = artist
        @title = title
        @genre = genre
        @tracks = tracks
    end

    def print
        puts "Artist: #{artist}"
        puts "Title: #{title}"
        puts "Genre: #{$genre_names[genre]}"
        i = 0
        while i < tracks.length
            puts("Track: #{i+1}")
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

# BACKEND LOGIC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Reads in and returns a single track from the given file
def read_track(music_file)
    name = music_file.gets()
    location = music_file.gets()
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
    album_genre = music_file.gets().to_i()
    tracks = read_tracks(music_file)
    album = Album.new(album_artist, album_title, album_genre, tracks)
    return album
end

# Returns an array of albums read from the given file
def read_albums(music_file)
    count = music_file.gets().to_i()
    albums = Array.new()
    i = 0
    while i < count
        album = read_album(music_file)
        albums << album 
        i += 1
    end
    return albums
end
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# MENUS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Prompts user to provide a filepath to the file storing the albums
def menu_read_in_albums()
    puts('Enter the file path to the file you wish to read albums from.')
    filepath = gets.chomp()
    music_file = File.new(filepath, "r")
    @albums = read_albums(music_file)
    music_file.close()
end

# Displays available albums
def menu_display_albums()
    finished = false
    begin
        puts('')
        puts('Display Menu:')
        puts('1) Display all albums')
        puts('2) Search by genre')
        puts('3) Back')
        choice = read_integer_in_range("Please enter your choice:", 1, 3)
        case choice
        when 1
            i = 0
            while i < @albums.length()
                puts("\nAlbum ID: #{i+1}")
                @albums[i].print()
                i+=1
            end
        when 2
            genres = ''
            i = 1
            while i < $genre_names.length()
                genres += $genre_names[i] + ' | '
                i += 1
            end
            puts('Please enter a genre name. | ' + genres)
            genre = gets.chomp()

            if $genre_names.include?(genre)
                i = 0
                while i < @albums.length()
                    if $genre_names[@albums[i].genre] == genre
                        puts("\nAlbum ID: #{i+1}")
                        @albums[i].print()
                    end          
                    i+=1
                end
            else
                puts('Invalid genre.')
            end

        when 3
            finished = true;
        else
            puts('Please select again')
        end
    end until finished
end

# Prompts user to select an album for playback
def menu_select_album_to_play()
end

# Prints the update ablum menu to the terminal
def menu_update_existing_album()
    finished = false
    begin
        puts('Maintain Albums Menu:')
        puts('1 To Update Album Title')
        puts('2 To Update Album Genre')
        puts('3 To Enter Album')
        puts('4 Exit')
        choice = read_integer_in_range("Please enter your choice:", 1, 4)
        case choice
        when 1
            puts('You selected Update Album Title.')
            read_string("Press enter to continue")
        when 2
            puts('You selected Update Album Genre.')
            read_string("Press enter to continue")
        when 3
            puts('You selected Enter Album.')
            read_string("Press enter to continue")
        when 4
            finished = true;
        else
            puts('Please select again')
        end
    end until finished
end

# Prints the main menu to the terminal
def menu_main()
    music_file = File.new("albums.txt", "r")
    @albums = read_albums(music_file)
    music_file.close()

    finished = false
    begin
        puts('Main Menu:')
        puts('1) Read in Albums')
        puts('2) Display Albums')
        puts('3) Select Album to play')
        puts('4) Update an existing Album')
        puts('5) Exit')
        choice = read_integer_in_range("Please enter your choice:", 1, 5)
        case choice
        when 1
            menu_read_in_albums()
        when 2
            menu_display_albums()
        when 3
            menu_select_album_to_play()
        when 4
            menu_update_existing_album()
        when 5
            finished = true;
        else
            puts('Please select again')
        end
    end until finished
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def main()
    music_file = File.new("albums.txt", "r")
    albums = read_albums(music_file)
    music_file.close()

    menu_main()
    
end
    
main()
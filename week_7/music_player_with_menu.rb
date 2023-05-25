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
    attr_accessor :id, :artist, :title, :genre, :tracks

    def initialize (artist, title, genre, tracks)
        @id = -1
        @artist = artist
        @title = title
        @genre = genre
        @tracks = tracks
    end

    def print
        puts "\n-------------------------\nAlbum ID: #{@id}"
        puts "Artist: #{artist}"
        puts "Title: #{title}"
        puts "Genre: #{$genre_names[genre]}"
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
        album.id = i
        albums << album 
        i += 1
    end
    return albums
end

# Take an array of albums and return array of albums that match given genre
def get_albums_by_genre(albums, genre) 
    result = Array.new()
    i = 0
    while i < albums.length()
        if $genre_names[albums[i].genre] == genre
            result << albums[i]
        end          
        i+=1
    end
    return result
end

# Take an array of albums and return album that matches given id
def get_album_by_id(albums, id)
    found = nil
    i = 0
    while i < albums.length()
        if albums[i].id == id
            found = albums[i]
            i = albums.length()
        end          
        i+=1
    end
    return found
end


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Print an array of albums to the terminal
def print_albums(albums)
    i = 0
    while i < albums.length()
        albums[i].print()
        i+=1
    end
    puts ("\nNo albums found.") if albums.length < 1
end



# MENUS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Prompts user to select an album for playback
def menu_select_album()
    selected = get_album_by_id(@albums, read_integer("\nEnter album ID:"))
    puts("\nNo album matching that ID was found.") if selected == nil
    return selected
end

# Prints the update album menu to the terminal
def menu_update_existing_album()
    album = menu_select_album()
    if(album)
        album.print()
        options = ['Update Album Title', 'Update Album Genre', 'Back']
        case choice = input_menu('UPDATE ALBUM MENU', 'Please enter your choice:', options)
        when 1
            album.title = read_string("Enter new album title:")
        when 2
            choice = input_menu('SELECT A NEW GENRE', 'Please enter your choice:', $genre_names)
            genre = $genre_names[choice - 1]
            album.genre = choice-1         
        end  
    end
end

# Prompts user to select an album for playback
def menu_select_album_to_play()

    album = menu_select_album()
    if(album)
        album.print()
        if(album.tracks.length > 0)
            choice = read_integer_in_range("\nPlease enter the track number you wish to play:", 1, album.tracks.length)
            puts("\nPlaying #{album.tracks[choice - 1].name}")
            
            1.upto(10) do
                print("♫ ")
                sleep 1
            end
            puts('')
        else
            puts("\nThe selected album has no tracks to play.")
        end
    end
end

# Prints the album display menu to the terminal
def menu_display_albums()

    options = ['Display all albums', 'Search by genre', 'Back']
    case choice = input_menu('DISPLAY MENU', 'Please enter your choice:', options)
    when 1
        print_albums(@albums)
    when 2
        choice = input_menu('SELECT A GENRE TO SEARCH FOR', 'Please enter your choice:', $genre_names)
        genre = $genre_names[choice - 1]
        print_albums(get_albums_by_genre(@albums, genre)) 
    end
end

# Prompts user to provide a filepath to the file storing the albums
def menu_read_in_albums()

    options = ['Load default album file', 'Enter filepath', 'Back']
    case choice = input_menu('LOAD ALBUMS MENU', 'Please enter your choice:', options)
    when 1
        music_file = File.new("albums.txt", "r")
        @albums = read_albums(music_file)
    when 2
        puts('Enter the file path to the file you wish to read albums from.')
        filepath = gets.chomp()
        music_file = File.new(filepath, "r")
        @albums = read_albums(music_file)
        music_file.close()
    when 3
        finished = true;
    end
end

# Prints the main menu to the terminal
def menu_main()
    finished = false
    begin
        options = ['Read in Albums', 'Display Albums', 'Select Album to play', 'Update an existing Album', 'Exit']
        choice = input_menu('MAIN MENU', 'Please enter your choice:', options)

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
        end
    end until finished
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def main()
    @albums = Array.new()
    menu_main()
end
    
main()
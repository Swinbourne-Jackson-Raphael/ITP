require './input_functions'

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
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

# reads in a single track from the given file.
def read_track(a_file)
    name = a_file.gets().chomp
    location = a_file.gets().chomp
    track = Track.new(name, location)
    return track
end

# Takes an array of tracks and prints them to the terminal
def print_tracks(tracks)
  i = 0
  while i < tracks.length
    print_track(tracks[i])
    i+=1
  end
end

# Takes a single track and prints it to the terminal
def print_track(track)
  puts(track.name)
	puts(track.location)
end

# search for track by name.
# Returns the index of the track or -1 if not found
def search_for_track_name(tracks, search_string)
    found_index = -1
    i = 0
    while i < tracks.length

        if(tracks[i].name == search_string) 
            found_index = i;
            i = tracks.length
        end

        i+=1
    end
    return found_index
end
    
def main()
    music_file = File.new("album.txt", "r")
    tracks = read_tracks(music_file)
    music_file.close()
    print_tracks(tracks) 

    search_string = read_string("Enter the track name you wish to find: ")
    index = search_for_track_name(tracks, search_string)
    if index > -1
        puts "Found " + tracks[index].name + " at " + index.to_s()
    else
        puts "Entry not Found"
    end
end

main()
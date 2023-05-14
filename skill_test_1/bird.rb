require './input_functions'

class Bird 
	attr_accessor :id, :caught_location, :species, :cage_number

	def initialize(id, caught_location, species, cage_number)
		@id = id
        @caught_location = caught_location
		@species = species
        @cage_number = cage_number
	end
end

def read_bird()
	id = read_integer('Enter bird id:')
	caught_location = read_string('Enter bird location:')
	species = read_string('Enter bird species:')
	cage_number = read_integer('Enter bird cage number:')
	return Bird.new(id, caught_location, species, cage_number)
end

def read_birds()
	birds = Array.new()
	count = read_integer('How many birds are you entering:')
	i = 0
	while i < count
		birds << read_bird()
		i += 1
	end
	return birds
end

def print_bird(bird)
	puts("Id: #{bird.id}")
	puts("Location: #{bird.caught_location}")
	puts("Species: #{bird.species}")
	puts("Cage number: #{bird.cage_number}")
end

def print_birds(birds)
	i = 0
	while i < birds.length
			print_bird(birds[i])
			i += 1
	end
end

def main()
	birds = read_birds()
	print_birds(birds)
end

main()

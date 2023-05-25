
# Takes a number and writes that number to a file then on each line
# increments from zero to the number passed
def write(aFile, number)
    aFile.puts(number.to_s)
    index = 0
    while (index < number)
     aFile.puts(index.to_s)
     index += 1
    end
end
  
# Read the data from the file and print out each line
def read(aFile) 
    count = aFile.gets().chomp()
    if (is_numeric?(count))
        count = count.to_i
        index = 0
        while (index < count)
            line = aFile.gets
            puts "Line read: " + line
            index += 1
        end
    else
        puts "Error: first line of file is not a number"
    end
end

# Returns true if a string contains only digits
def is_numeric?(obj) 
    obj.match(/^(-)?\d+$/) ? true : false 
end
  
# Write data to a file then read it in and print it out
def main
    aFile = File.new("mydata.txt", "w") # open for writing
    write(aFile, 10)
    aFile.close

    aFile = File.new("mydata.txt", "r") # open for reading
    read(aFile)   
    aFile.close
end
  
main
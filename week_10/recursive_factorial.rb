# Recursive Factorial
def factorial(n)
    if n <= 1
        return 1
    else
        return n * factorial(n - 1)
    end
end

def main
    input_arr = ARGV
    if input_arr.length < 1
        puts "Error - Please provide a number as command line argument."
    else
        number = input_arr[0].to_i
        if number < 1
            puts "Incorrect argument - need a single argument with a value of 0 or more."
        else
            result = factorial(number) # Call recursive factorial func
            puts result
        end
  end 
end

main

# Jackson Raphael
# 104634814@student.swin.edu.au
# Swinbourne University ITP-TP1-2023

# GENERAL MATH FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Square a given number
def squared(number)
    return number * number
end


# VECTOR FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Distance between two 2D vectors
def vec2D_distance(v1, v2) 
    return Math.sqrt(squared(v2[0] - v1[0]) + squared(v2[1] - v1[1]))
end


# TRIG FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Convert an angle from degrees to radians.
def deg_to_rads(angle)
    return (3.14159265359/180) * angle
end

# Convert an angle from radians to degrees.
def rads_to_deg(angle)
    return angle * (180/3.14159265359)
end

# Calculate a directional 2D vector from a radian angle.
# An angle of 0 points to the right of the screen.
def angle_to_dir_vector(angle)
    x = Math.cos(angle)
    y = Math.sin(angle)
    return Vector[x, y]
end

# Covert a directional 2D vector to an angle.
def dir_vector_to_angle(direction)
    return Math.atan2(direction[1], direction[0])
end

# Calculate a world direction from the difference between two angles.
def angle_diff_to_world_dir(a1, a2)
    angle_to_dir_vector(a1 - a2)
end

# Calculate world velocity from velocity of v1(relative to world) and velocity of v2(relative to v1)
def rel_vel_to_world_vel(v1, v2)
    return v1 + v2
end

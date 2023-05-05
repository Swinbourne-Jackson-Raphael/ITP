# Jackson Raphael
# 104634814@student.swin.edu.au
# Swinbourne University ITP-TP1-2023

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
def angle_to_dir_vector(angle)
    x = Math.cos(angle)
    y = Math.sin(angle)
    return Vector[x, y]
end

# Calculate a world direction from the difference between two angles.
def angle_diff_to_world_dir(a1, a2)
    angle_to_dir_vector(a1 - a2)
end

# Calculate world velocity from velocity of v1(relative to world) and velocity of v2(relative to v1)
def rel_vel_to_world_vel(v1, v2)
    return v1 + v2
end


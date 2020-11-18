x = 1
x += 3 # finally python-like increments
x *= 3

v = [1, 2, 3]
println(v.^2)
println(v'*v)

# complex numbers :)
z = 3 - 4im
abs(z)
abs2(z)
rad2deg(angle(z))

# rational numbers -- interesting
2//3 + 1//3
x = 1//25 + 2//30
numerator(x)
denominator(x)
#=
String manipulation
=#

"""This string can include "quotes" without breaking the string"""

# This is a char, not a string
'a'

# String interpolation/formatting
name = "Travis"
age = 30

println("My name is $name, I'm $age years old")

# String concatenation
s1 = string("One string", " is concatenated with another")
println(typeof(s1))
s2 = "First string" * " appended to second"
println(typeof(s2))

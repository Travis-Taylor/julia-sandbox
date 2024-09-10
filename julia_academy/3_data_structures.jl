#= Built-in Data Structures
- Dictionaries
- Tuples
- Arrays
=#

# Dicts
key_values = Dict("key1" => "value1")
key_values["key2"] = "value2"

value1 = pop!(key_values, "key1")
println(value1)
# NOTE: Not indexable (by int position)

# Tuples
top_restaurants = ("uchi", "xicamiti", "bonfire burritos")
# 1-based indexing????? wtf Matlab
println(top_restaurants[1])
# Not assignable

# Arrays
fibonacci = [1, 1, 2, 3, 5, 8, 13]
println(typeof(fibonacci))
mixed_type = [1, 2.0, "3"]
println(typeof(mixed_type))
println(mixed_type[2])

# !-appended functions seems to indicate mutation of the argument
push!(fibonacci, 21)
println(fibonacci)
val = pop!(fibonacci)
println(fibonacci)
println(val)

## 2D Array
numbers = [[1, 2, 3], [3, 2, 1], [7, 6, 5]]
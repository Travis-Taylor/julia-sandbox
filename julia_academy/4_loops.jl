#= Control Flow - Loops
- while
- for
=#

n = 100
while n > 0
    # global declaration to use the existing n from outer scope
    global n
    println("n is now $n")
    n -= 5
end

# For loops
iterable = ["turkey", "chicken", "tofu", "beef", "fish"]
for protein in iterable
    println("Chimichangas with $protein")
end

# integer range using : operator
numbers = []
for ii = 1:9
    println("num: $ii")
    push!(numbers, ii)
end

# fancy "element of" range operator
for jj ∈ 1:9
    @assert numbers[jj] == jj
end

# built-in helpers for 2D zeroes array
m, n = 4, 4
# 4x4 array of 0s
arr = fill(0, (m, n))
# Can also create with array comprehension
alt_array = [ii + jj for ii in 1:m, jj in 1:n]

# Fancy double for-loop iteration!
for ii in 1:m, jj in 1:n
    arr[ii, jj] = ii + jj
    @assert arr[ii, jj] == alt_array[ii, jj]
end

#= Exercises
4.1 - loop over integers between 1 & 100, print their squares
=#
for ii in 1:100
    println(ii * ii)
end

# 4.2 - Create dictionary holding keys of integers containing their square as values
squares = Dict()
for ii in 1:100
    squares[ii] = ii ^ 2
end
@assert squares[10] == 100
@assert squares[11] == 121

# 4.3 - Use array comprehension to create squares_arr storing the squares for ints from 1-100
squares_arr = [ii ^ 2 for ii in 1:100]
@assert length(squares_arr) == 100
@assert sum(squares_arr) == 338350

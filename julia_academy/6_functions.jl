#= Functions
- Basics
- duck-typing

=#

function cool_fun(cool_param)
    println("Processing $cool_param")
    cool_param + 1
end

val = cool_fun(1)
# Alternate syntax
alt_fun(param) = begin
    println("Processing $param"); 
    param + 1
end

@assert cool_fun(12) == alt_fun(12)

# Anonymous/lambda functions
anon_fun = param -> begin
    println("Processing $param")
    param + 1
end
@assert anon_fun(50) == alt_fun(50)

# Duck-Typing - accept whatever input makes sense
function square(in)
    in * in
end

# Accepts numeric input
square(7)
# Accepts string input
square("double string -")
matrix = fill(0, (2, 2))
# Accepts 2D array, because multiplication is well-defined
square(matrix)

# Mutation (denoted by !, I knew it!)
v = [1, 3, 2]
sort(v)
@assert v[2] == 3
sort!(v)
@assert v[2] == 2

# Broadcasting - element-wise function evaluation over iterable elements

A = [jj + 3*ii for ii in 0:2, jj in 1:3]
println(A)
A_squared = square(A)
@assert A * A == A_squared
# vs
elements_squared = square.(A)
for ii = 1:3, jj = 1:3
    @assert elements_squared[ii, jj] == A[ii, jj] ^ 2
end
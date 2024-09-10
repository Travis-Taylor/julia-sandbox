#=
Basic intro to the language features:
- unicode variable support (emoji var name)
- lazy/dynamic type evaluation
- syntactic similarity to python3
=#
println("Some text")

some_var = "some value"
int_var = 24
🍣 = 3.1415926535
println(typeof(some_var))
println(typeof(int_var))
println(typeof(🍣))

#= Exercise - Assign 365 to a variable named days. Convert days to a float and assign it to
variable days_flloat
=# 
days = 365
days_float = convert(Float32, days)

@assert days == 365
@assert days_float == 365.0

println(parse(Int64, "1"))
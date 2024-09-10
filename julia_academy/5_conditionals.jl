# Conditionals #

x = 1
y = 100
if x > y
    println("$x is less than $y")
elseif y > x
    println("$x is greater than $y")
else
    println("Both values are $x")
end

# Supports ternary operator
# Return greater of the 2 numbers
z = x > y ? x : y
println(z)

# Supports short-circuit evaluation
x < y && (y / 0) # no zero division 🎉
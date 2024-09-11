#= Multiple Dispatch
Dynamic determination of function signature to invoke, based on inputs
=#

import Base: +

# no such overload for + exists to allow: "hello " + "world"
# we can define it ourselves
+(x::String, y::String) = string(x, y)
println("hello " + "world")


foo(x, y) = println("Generic foo")
foo(x::Int, y::Float64) = println("foo with integer + float")
foo(x::Float64, y::Float64) = println("foo with 2 floats")
foo(x::Int, y::Int) = println("foo with 2 integers")

foo(1, 1)
foo(1., 1.)
foo(1, 1.0)
foo(true, "something")
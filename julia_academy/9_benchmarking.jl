#= Julia Benchmarking
Comparing Julia, C, and Python run-times of sum
=#
using BenchmarkTools
sample = rand(10^7)
expected_total = sum(sample)
println("Expected sum is $expected_total")
results = Dict{String,Float64}()

function run_benchmark(test_fn, name)
    total = test_fn(sample)
    #= Interesting built-in ≈ symbol, alias for `isapprox` 
    calculates approximate equality, within some tolerance =#
    @assert total ≈ expected_total "$name did not successfully calculate the expected sum"
    test_bench = @benchmark $test_fn($sample)
    fastest_time = minimum(test_bench.times)
    println("$name: Fastest time was $(fastest_time / 1e6)ms")
    results[name] = fastest_time
end

## Julia Built-in ##
j_total = sum(sample)
run_benchmark(sum, "Julia")


## Julia SIMD (Single-Input-Multiple-Data) ##
function sum_simd(input)
    s = 0.0
    @simd for a in input
        s += a
    end
    s
end
run_benchmark(sum_simd, "Julia w/ SIMD")

## C Impl ##
using Libdl
c_code = """
#include <stddef.h>
double c_sum(size_t n, double *X) {
    double s = 0.0;
    for (size_t ii = 0; ii < n; ii++) {
        s += X[ii];
    }
    return s;
}
"""
# Create & compile a c lib
const c_lib = tempname()

# pipe code snippet directly to gcc command
open(`gcc -fPIC -O3 -msse3 -xc -shared -ffast-math -o $(c_lib * "." * Libdl.dlext) -`, "w") do f
    print(f, c_code)
end

# wrap in Julia function
c_sum(X::Array{Float64}) = ccall(("c_sum", c_lib), Float64, (Csize_t, Ptr{Float64}), length(X), X)
run_benchmark(c_sum, "C w/ -ffast-math")

## Python Built-in ##
using PyCall

# get the builtin "sum" fn
pysum = pybuiltin("sum")
run_benchmark(pysum, "Python builtin")

## Python NumPy ##
numpy_sum = pyimport("numpy")["sum"]
run_benchmark(numpy_sum, "NumPy")

## Final Summary ##
println("Overall results:")
for (key, value) in sort(collect(results), by=last)
    time_ms = value / 1e6
    println(rpad(key, 25, "."), lpad("$(round(time_ms; digits=1))ms", 6, "."))
end
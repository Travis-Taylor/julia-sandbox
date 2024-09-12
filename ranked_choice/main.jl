#= Ranked Choice Voting simulation
Basic 4-choice implementation of ranked choice voting.
When a voter's first choice is eliminated from the running, their second will be
used to re-tally results, and so on until a candidate has a majority

Inputs to the results will be weighted preference of candidates and write-in
options, as well as the number of voters.

TODO(ttaylor) variable number of backup choices?
TODO(ttaylor) maybe axes of different policy paradigms (e.g. economic views vs
social views)
=#
using StatsBase

# Ranked-choice Vote struct, allowing 4 choices in order of preference
struct Vote
    first::String
    second::String
    third::String
    fourth::String

    function Vote(choices::Tuple{String,String,String,String})
        new(choices...)
    end
end

candidates::Vector{String} = ["Sheetal", "James", "Natsuki", "Kalae"]
candidate_popularity = Dict{String,Float32}()
#= Stand-in value for write-in candidates; actual candidate value will be
evaluated with `gen_write_in` when Vote is initialized =#
writein = "write-in"

# Assume write-in candidates are effectively random
function gen_write_in()::String
    "SomeCandidate$(rand(0:typemax(Int16)))"
end
push!(candidates, writein)
# Also assume write-in candidates are fairly unlikely
candidate_popularity[writein] = rand(0.0:0.01:0.15)
writein_likelihood = round(candidate_popularity[writein], digits=2) * 100


## Randomized Inputs ##
# Normalized popularity in range [0-1]
for candidate ∈ candidates
    candidate_popularity[candidate] = rand(Float32)
    approval_percent = round(candidate_popularity[candidate], digits=2) * 100
    println("Candidate $candidate approval rating: $approval_percent%")
end

println("$writein candidates likelihood: $writein_likelihood%")


# Voting Population
num_voters = 1000000

# Generate votes
votes = Vector{Vote}()
candidate_weights = Weights(collect(values(candidate_popularity)))
for ii ∈ 1:num_voters
    choices = Vector{String}()
    remaining_candidates = copy(candidates)
    remaining_popularity = copy(candidate_popularity)
    for choice in 1:4
        remaining_weights = Weights(collect(values(remaining_popularity)))
        candidate = sample(remaining_candidates, remaining_weights)
        if candidate == writein
            push!(choices, gen_write_in())
            # Don't remove writein from options, they can write in more than 1
        else
            push!(choices, candidate)
            # Remove this choice from the remaining candidate list
            filter!(el -> el ≠ candidate, remaining_candidates)
            pop!(remaining_popularity, candidate)
        end
    end
    vote = Vote((choices...,))
    push!(votes, vote)
end


